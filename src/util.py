from enum import StrEnum
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from os import listdir, path
from pathlib import Path
from colorhash import ColorHash
from collections import Counter
from itertools import islice
from weasyprint import HTML, CSS
import yaml


class State(StrEnum):
    ACTIVE = "active"
    IDLE = "idle"

    def __repr__(self):
        return str(self)


class Metric(StrEnum):
    """
    Check we can loop over the metrics

    >>> len(list(Metric))
    3
    """

    MEAN = "mean"
    STD = "std"
    FFT = "fft"
    # BOTH = "both"
    # MEAN_NO_OUTLIERS = "mean_no_outliers"

    def fancy_name(self):
        match self.value:
            case "mean":
                return "μ"
            case "std":
                return "σ"
            case _:
                return self.value


class TraceType(StrEnum):
    TRAINING = "model"
    TESTING = "testing"


class Trace:
    """
    Represents a single contiguous period of data. Either training or testing.

    run all windows, return metrics in the form [{'mean': value, 'std': value}], where the values are sorted

    the first window takes up s samples, so there are len(data) - s samples left. each addional window uses up o spaces.
    >>> exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 10, 2)
    >>> len(c.devices)
    32
    >>> len(exp.devices)
    32
    >>> len(exp.data)
    32
    >>> len(Trace(exp.data[0], pd.DataFrame(data={'power_mW': [1] * 100}), TraceType.TRAINING).profile)
    46

    # Additonal partial windows aren't counted
    >>> len(Trace(exp.data[0], pd.DataFrame(data={'power_mW': [1] * 101}), TraceType.TRAINING).profile)
    46

    Non overlapping windows
    >>> exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 10, 20)
    >>> len(exp.devices)
    32
    >>> len(exp.data)
    32
    >>> len(Trace(exp.data[0], pd.DataFrame(data={'power_mW': [1] * 100}), TraceType.TRAINING).profile)
    5

    >>> Trace(exp.data[0], pd.DataFrame(data={'power_mW': [1] * 50 + [2] * 50}), TraceType.TRAINING).profile # doctest: +NORMALIZE_WHITESPACE
    [{<Metric.MEAN: 'mean'>: np.float64(0.0010000000000000002), <Metric.STD: 'std'>: np.float64(2.28569887277129e-19), <Metric.FFT: 'fft'>: np.float64(0.01)}, {<Metric.MEAN: 'mean'>: np.float64(0.0010000000000000002), <Metric.STD: 'std'>: np.float64(2.28569887277129e-19), <Metric.FFT: 'fft'>: np.float64(0.01)}, {<Metric.MEAN: 'mean'>: np.float64(0.0010000000000000002), <Metric.STD: 'std'>: np.float64(2.28569887277129e-19), <Metric.FFT: 'fft'>: np.float64(0.01)}, {<Metric.MEAN: 'mean'>: np.float64(0.0020000000000000005), <Metric.STD: 'std'>: np.float64(4.57139774554258e-19), <Metric.FFT: 'fft'>: np.float64(0.02)}, {<Metric.MEAN: 'mean'>: np.float64(0.0020000000000000005), <Metric.STD: 'std'>: np.float64(4.57139774554258e-19), <Metric.FFT: 'fft'>: np.float64(0.02)}]

    >>> exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 400, 10)
    >>> len(Trace(exp.data[0], pd.DataFrame(data={'power_mW': [1] * 1750}), TraceType.TRAINING).profile)
    136

    >>> exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 400, 10)

    Are all the profiles the same length?

    >>> len(exp.devices)
    32
    >>> len(exp.data)
    32

    >>> [len(data.training.profile) for data in exp.data]
    [111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111, 111]
    >>> [len(data.testing.profile) for data in exp.data]
    [38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38, 38]

    TODO do we want non rectangular windows? are edge effects important

    # TODO fix outlier removal, maybe could be in a different function
            # compute a mean with outliers removed, values that fall outside of 3 std
            # mean_mean = np.mean(means)
            # three_std = 2 * np.std(means)

            # means_no_outliers = [
            #     mean
            #     for mean in means
            #     if mean > mean_mean - three_std and mean < mean_mean + three_std
            # ]
    """

    def __init__(self, data: Data, df: pd.DataFrame, type: TraceType):
        self.data = data
        self.df = df
        self.type = type
        self.profile: list[dict[Metric, float]] = []
        for bin in range(
            (len(self.df) - self.data.experiment.w) // self.data.experiment.s + 1
        ):
            window_power = (
                self.df.iloc[
                    bin * self.data.experiment.s : bin * self.data.experiment.s
                    + self.data.experiment.w
                ].power_mW
                / 1000
            )
            self.profile.append(
                {
                    Metric.MEAN: window_power.mean(),
                    Metric.STD: window_power.std(),
                    Metric.FFT: np.abs(np.fft.fft(window_power)[0]),
                }
            )


class Data:
    """
    >>> [len(data.training.df) for data in exp.data]
    [1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500, 1500]


    >>> [len(data.testing.df) for data in exp.data]
    [778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778, 778]
    """

    def __init__(self, exp: Experiment, device: Device, state: State, df: pd.DataFrame):
        self.experiment = exp
        self.device = device
        self.state = state
        if device.dir_name == "nestmini2":
            df = df.rename(columns={"power_W": "power_mW"})

        split = (
            25
            * 60
            # 25 minutes of training data, gurantees at least 10 minutes of testing data
        )
        self.training = Trace(self, df.iloc[:split, :], TraceType.TRAINING)
        self.testing = Trace(self, df.iloc[split:, :], TraceType.TESTING)

    def __repr__(self):
        return f"<{self.device}, {self.state}>"


class Context:
    """
    Get all the devices and categories.

    Hard coded to remove echodot3 since the idle data is truncated and can't be compared
    >>> len(c.devices)
    32

    >>> c.categories
    ['lights', 'audio', 'camera', 'tv', 'appliance']


    >>> c.devices[:5]
    [Antela Light, Fitop Light, LIFX Light, Lepro Light, Tapo Light]

    My data
    >>> my = Context("My Data")
    >>> len(my.devices)
    6

    """

    def __init__(
        self,
        dataset_name: str,
    ):
        file_path = Path(__file__).parent
        with open(file_path / "../common.yaml") as f:
            self.config = yaml.safe_load(f)
        dataset = self.config["datasets"][dataset_name]
        self.path = file_path / ".." / dataset["path"]
        if "categories" in dataset:
            cat_key = lambda cat: dataset["categories"].index(cat)

            self.categories = sorted(listdir(self.path), key=cat_key)
            self.devices = sorted(
                [
                    Device(device, category)
                    for category in self.categories
                    for device in listdir(f"{self.path}/{category}")
                    if "exclude" not in dataset or device not in dataset["exclude"]
                    if path.isdir(f"{self.path}/{category}/{device}")
                ],
                key=lambda device: (
                    cat_key(device.category),
                    device.name(),
                ),
            )
        else:
            self.devices = sorted(
                [
                    Device(device, None)
                    for device in listdir(self.path)
                    if "exclude" not in dataset or device not in dataset["exclude"]
                    if path.isdir(f"{self.path}/{device}")
                ],
                key=lambda device: (device.name(),),
            )

    def device_from_name(self, device_name):
        return [device for device in self.devices if device.dir_name == device_name][0]


def map_device_names(name):
    match name:
        case "appletv":
            return "Apple TV"
        case "LGtv":
            return "LG TV"
        case "samsungtv":
            return 'Samsung 32" TV'
        case "samsungtvsmall":
            return "Samsung Small TV"
        case "tcltv":
            return "TCL TV"
        case "toshiba":
            return "Toshiba TV"
        case "yeelight4":
            return "Yeelight Light"
        case "wiz":
            return "Wiz Light"
        case "tapo":
            return "Tapo Light"
        case "lifx":
            return "LIFX Light"
        case "lepro":
            return "Lepro Light"
        case "fitop":
            return "Fitop Light"
        case "antela":
            return "Antela Light"
        case "yibefb":
            return "Yi Camera"
        case "hualai":
            return "Hualai Camera"
        case "google1d15":
            return "Google Nest Camera"
        case "boifun80c0":
            return "Boifun Baby Camera"
        case "bluram6da9":
            return "Blurams Camera"
        case "amcrest266e":
            return "Amcrest Camera"
        case "bose":
            return "Bose Speaker"
        case "echodot3":
            return "Echo Dot 3 Speaker"
        case "echodot5":
            return "Echo Dot 5 Speaker"
        case "echospot":
            return "Echo Spot 5 Speaker"
        case "googlehome":
            return "Google Home Speaker"
        case "homepod":
            return "Homepod Speaker"
        case "nestmini2":
            return "Nest Mini 2 Speaker"
        case "sonos":
            return "Sonos Speaker"
        case "cosori":
            return "Cosori Air Fryer"
        case "honeywell":
            return "Honeywell Thermostat"
        case "levoit":
            return "Levoit Air Purifier"
        case "swan":
            return "Swan Smart Kettle"
        case "xiaomiblender":
            return "Xiaomi Blender"
        case "weekett":
            return "Weekett Kettle"


class Device:
    def __init__(self, dir_name: str, category):
        self.dir_name: str = dir_name
        self.category = category
        self.nice_name = map_device_names(dir_name)
        self.colour = ColorHash(dir_name).hex

    def __str__(self):
        return self.name()

    def __repr__(self):
        return self.name()

    # Get the nice name if needed
    def name(self):
        if self.nice_name:
            return self.nice_name
        else:
            return self.dir_name


class Classifier(StrEnum):
    Median = "Median"
    Centroid = "Centroid"


class Experiment:
    """
    Verify the new devices are seperate

    >>> context = Context("SafeNetIoT")
    >>> exp = Experiment(context, [State.IDLE], [Metric.MEAN], Classifier.Median, 180, 10)

    >>> context.devices.pop()
    Xiaomi Blender
    >>> len(exp.devices)
    32

    >>> len(exp.data)
    32

    >>> all(['power_mW' in data.training.df.columns for data in exp.data])
    True

    >>> all(['power_mW' in data.testing.df.columns for data in exp.data])
    True

    Filtering
    >>> len(Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 180, 10, include=['appletv', 'samsungtv', 'cosori']).devices)
    3

    """

    def __init__(
        self,
        context: Context,
        states: list[State],
        metrics: list[Metric],
        classify_by: Classifier,
        w=None,
        s=None,
        threshold=None,
        include=[],
    ):
        self.context = context
        self.states: list[State] = states
        self.metrics = metrics
        self.classify_by = classify_by
        self.w: int = context.config["w"] if w is None else w
        if self.w > 600:
            raise ValueError(self.w)
        self.s: int = context.config["s"] if s is None else s

        self.threshold = threshold

        if include == []:
            include = list(map(lambda device: device.dir_name, context.devices))
        self.devices = [
            device for device in context.devices if device.dir_name in include
        ]

        dfs = {
            (device, state): pd.read_csv(
                f"{self.context.path}/{device.category}/{device.dir_name}/{state}.csv",
                parse_dates=["timestamp"],
            )
            for state in self.states
            for device in self.devices
            if device.dir_name in include
        }

        # truncate the data to the shortest one
        least = min([len(df) for df in dfs.values()])
        self.data: list[Data] = [
            Data(self, device, state, df.iloc[:least, :])
            for (device, state), df in dfs.items()
        ]

        self.classes = self.classify_data()
        self.confusion_matrix = self.compute_confusion_matrix()
        self.f1_scores, self.precision, unknown = self.compute_scores()
        if self.threshold == None:
            assert all([x == 0 for x in unknown.values()])
        self.unknown = unknown
        self.f1_macro_average = sum(self.f1_scores.values()) / len(self.f1_scores)

    def __repr__(self):
        return f"{"-".join(self.states)}_{"-".join(self.metrics)}_{self.classify_by}_{self.w}_{self.s}"

    def classify_data(self: Experiment):
        """
        for each of the testing datasets in an experiment, predict the device they are based on the training data

        # are all the lengths the same?
        >>> len(set([v.total() for v in exp.classes.values()]))
        1

        >>> exp.f1_macro_average
        np.float64(0.742989379804219)

        >>> fft1 = Experiment(c, [State.IDLE], [Metric.FFT], Classifier.Median, 600, 100)
        >>> fft1.f1_macro_average
        np.float64(0.7083333333333334)
        >>> fft = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 600, 100)
        >>> fft.f1_macro_average
        np.float64(0.7083333333333334)
        >>> fft = Experiment(c, [State.IDLE], [Metric.MEAN, Metric.STD], Classifier.Median, 600, 100)
        >>> fft.f1_macro_average
        np.float64(0.8145833333333333)
        >>> fft = Experiment(c, [State.IDLE], [Metric.MEAN, Metric.STD, Metric.FFT], Classifier.Median, 600, 100)
        >>> fft.f1_macro_average
        np.float64(0.7083333333333334)

        """
        if self.classify_by == Classifier.Median:
            training_profiles = {
                (data.device, data.state): {
                    metric: np.median(
                        [point[metric] for point in data.training.profile]
                    )
                    for metric in self.metrics
                }
                for data in self.data
            }
        elif self.classify_by == Classifier.Centroid:
            # device: {"std": centroid_std, "mean": centroid_mean}
            training_profiles = {
                (data.device, data.state): {
                    metric: sum([point[metric] for point in data.training.profile])
                    / len(data.training.profile)
                    for metric in self.metrics
                }
                for data in self.data
            }
        else:
            raise ValueError(self.classify_by)

        testing_profiles = {
            (data.device, data.state): data.testing.profile for data in self.data
        }
        matches: dict[tuple[Device, State], Counter[tuple[Device, State]]] = {}
        for dev_state, testing_profile in testing_profiles.items():
            closest: list[tuple[Device, State]] = []

            # find the closest training point for this
            # loop over all the testing windows
            for window_to_classify in testing_profile:
                # closest_prediction = None
                # dist = np.inf
                dists = list(
                    islice(
                        sort_dict_by_value(
                            {
                                predicted: np.sqrt(
                                    np.sum(
                                        [
                                            (
                                                window_to_classify[metric]
                                                - training[metric]
                                            )
                                            ** 2
                                            for metric in self.metrics
                                        ]
                                    )
                                )
                                for predicted, training in training_profiles.items()
                            }
                        ).items(),
                        2,
                    )
                )

                # TODO way to report dists / ratios?
                # ratio should judge the relative size. a smaller threshold means we allow closer together values
                # guranteed dist[0] < dist[1]. lets say 2x as big, then dist[1] / dist[0] = 2.
                #

                if (
                    self.threshold is None
                    or (dists[1][1] / dists[0][1] if dists[0][1] != 0 else 0)
                    >= self.threshold
                ):
                    closest.append(dists[0][0])

                # can get the number of expected classes later from list

            matches[dev_state] = Counter(closest)

        return matches

    def compute_confusion_matrix(self):
        """
        compute the confusion matrix using the given classes

        >>> exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 180, 10, include=['appletv', 'samsungtv', 'cosori'])
        >>> print(exp.confusion_matrix) # doctest: +NORMALIZE_WHITESPACE
        [[0.76666667 0. 0.23333333]
         [0.   1.   0.  ]
         [0.   0.   1.  ]]
        >>> exp.classes # doctest: +NORMALIZE_WHITESPACE
        {(Apple TV, idle): Counter({(Apple TV, idle): 46, (Cosori Air Fryer, idle): 14}), (Samsung 32" TV, idle): Counter({(Samsung 32" TV, idle): 60}), (Cosori Air Fryer, idle): Counter({(Cosori Air Fryer, idle): 60})}

        threshold
        >>> exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 150, 100, threshold = 2, include=['appletv', 'samsungtv', 'cosori'])
        >>> len(exp.devices)
        3

        make sure we don't add None to the data
        >>> len(exp.data)
        3
        >>> exp.classes
        {(Apple TV, idle): Counter({(Apple TV, idle): 5, (Cosori Air Fryer, idle): 1}), (Samsung 32" TV, idle): Counter({(Samsung 32" TV, idle): 7}), (Cosori Air Fryer, idle): Counter({(Cosori Air Fryer, idle): 7})}
        >>> exp.confusion_matrix # doctest: +NORMALIZE_WHITESPACE
        array([[0.71428571, 0.        , 0.14285714, 0.14285714],
           [0.        , 1.        , 0.        , 0.        ],
           [0.        , 0.        , 1.        , 0.        ],
           [0.        , 0.        , 0.        , 0.        ]])

        two states
        # >>> exp = Experiment(c, [State.IDLE, State.ACTIVE], [Metric.MEAN], Classifier.Median, 180, 10, include=['appletv', 'samsungtv', 'cosori'])
        # >>> exp.classes
        # {(Apple TV, idle): Counter({(Apple TV, idle): 42, (Cosori Air Fryer, idle): 14}), (Samsung 32" TV, idle): Counter({(Samsung 32" TV, active): 45, (Samsung 32" TV, idle): 11}), (Cosori Air Fryer, idle): Counter({(Cosori Air Fryer, idle): 56}), (Apple TV, active): Counter({(Apple TV, active): 56}), (Samsung 32" TV, active): Counter({(Samsung 32" TV, idle): 56}), (Cosori Air Fryer, active): Counter({(Cosori Air Fryer, active): 56})}
        # >>> exp.confusion_matrix
        """
        n = len(self.data)

        # add another
        if self.threshold:
            n = n + 1

        matrix = np.zeros((n, n))
        for i, class_ in enumerate(self.classes.values()):
            for (device, state), count in class_.items():
                data, j = self.get_data(device, state)
                classes = len(data.testing.profile)

                share = count / classes
                matrix[i][j] = share

                if self.threshold:
                    matrix[i][-1] = (classes - class_.total()) / classes

        return matrix

    def compute_scores(self):
        """
        f1 score for each thing

        not easy to convert into a list comprehension due to the variables and control flow

        >>> exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 180, 10, include=['appletv', 'samsungtv', 'cosori'])
        >>> exp.f1_scores
        {<Apple TV, idle>: np.float64(0.8679245283018868), <Samsung 32" TV, idle>: np.float64(1.0), <Cosori Air Fryer, idle>: np.float64(0.8955223880597015)}
        """

        f1_scores: dict[Data, float] = {}
        precision_scores: dict[Data, float] = {}
        unknown_rate: dict[Data, float] = {}
        n = len(self.confusion_matrix)
        # don't count the unknown row
        if self.threshold:
            n -= 1
            for i in range(n):
                unknown_rate[self.data[i]] = self.confusion_matrix[i, -1]
        else:
            for i in range(n):
                unknown_rate[self.data[i]] = 0

        for i in range(n):
            tp = self.confusion_matrix[i, i]
            fp: float = 0
            fn: float = 0
            for j in range(n):
                if j != i:
                    fn += self.confusion_matrix[j, i]
                    fp += self.confusion_matrix[i, j]
            f1_scores[self.data[i]] = 0 if tp == 0 else 2 * tp / (2 * tp + fp + fn)
            precision_scores[self.data[i]] = 0 if tp == 0 else tp / (tp + fp)

        return f1_scores, precision_scores, unknown_rate

    def get_device(self, name: str) -> Device:
        for device in self.devices:
            if device.nice_name == name or device.dir_name == name:
                return device
        raise ValueError(name)

    def get_data(self, device, state) -> tuple[Data, int]:
        for i, data in enumerate(self.data):
            if data.device == device and data.state == state:
                return data, i
        raise ValueError(device, state)


def sort_dict_by_value(dict, key=lambda x: x[1], reverse=False):
    """
    >>> sort_dict_by_value({'a': 2, 'b': 3, 'c': 1})
    {'c': 1, 'a': 2, 'b': 3}
    """

    return {k: v for k, v in sorted(dict.items(), key=key, reverse=reverse)}


# def intervalise(metric):
#     return pd.Interval(min(metric), max(metric))


def my_colormesh(fig, ax, x, y, z):
    cmap = "BuPu"
    im = ax.pcolormesh(
        x, y, z, cmap=cmap, shading="nearest", edgecolors="grey", linewidths=0.1
    )
    ax.tick_params("x", rotation=90)

    bar = fig.colorbar(im, ax=ax, orientation="vertical")
    ticks = np.linspace(0, 1, 11)
    bar.set_ticks(ticks=ticks, labels=map(lambda x: f"{x:.0%}", ticks))


def graph_confusion_matrix(exp: Experiment):
    # TODO better font scaling
    fig, ax = plt.subplots()
    names = [
        repr(exp.data) if len(exp.states) > 1 else data.device.name()
        for data in exp.data
    ]
    matrix = np.fliplr(exp.confusion_matrix)
    my_colormesh(
        fig,
        ax,
        names[::-1],
        names,
        matrix,
    )

    n = len(exp.data)
    for i in range(n):
        for j in range(n):
            share = matrix[i][j]
            if share != 0:
                colour = "black"
                if share > 0.45:
                    colour = "white"
                ax.text(
                    j,
                    i,
                    f"{share*100:.0f}",
                    fontsize=4 if n > 30 else 8,
                    # f"{share:.0%}",
                    # fontsize=n / 11,
                    ha="center",
                    va="center",
                    color=colour,
                )

    ax.set_ylabel("True Class")
    ax.set_xlabel("Predicted Class")
    # ax.set_title(
    # f"state={exp.state}, metric={exp.metric.fancy_name()}, w = {exp.w}, s = {exp.s}"
    # )
    ax.tick_params(axis="both", labelsize=7 if n > 30 else 11)
    # fig.set_dpi(400)
    # fig.
    filename = f"../generated/confusion-matrix-{'-'.join(exp.states)}-{exp.w}-{exp.s}-{"-".join(exp.metrics)}-{exp.classify_by}.pdf"
    # print(f"Wrote graph to {filename}")
    fig.savefig(filename, bbox_inches="tight")


# """
# Assuming sorted lists, return the number of non overlapping intervals

# >>> overlap(([1, 3], [2, 4], [10, 20]))
# 1
# """
# def overlap(intervals, metrics):
#     # TODO: look at multiple metrics here
#     independents = 0
#     for i, interval in enumerate(intervals):
#         independent = True
#         for j, compare in enumerate(intervals):
#             if i != j:
#                 overlaps = 0
#                 for metric in metrics:
#                     if interval[metric][0] <= compare[metric][-1] and compare[metric][0] <= interval[metric][-1]:
#                         overlaps += 1
#                 if overlaps == len(metrics):
#                     independent = False
#         if independent:
#             independents += 1

#     return independents


# def compute_overlap(data, samples, offset, metrics=['mean']):
#     results = {device: compute_profile(df, samples, offset) for device, (df, _) in data.items()}
#     return overlap(results.values(), metrics)


#  #| label: colourmesh

# """
# Find overlapping intervals, return the number of non-overlapping intervals and the total amount of overlap.

# A faster algorithm would place all on same numberline, then it's like the brackets problem. n log n
# Do naive n^2 algo for now.

# For 2d overlaps, do both? Any overlap counts.

# >>> overlap_intervals((pd.Interval(left=1, right=3), pd.Interval(left=2, right=4), pd.Interval(left=10, right=20)))
# 1
# """
# def overlap_intervals(intervals, metrics=['mean']):
#     # TODO: look at multiple metrics here
#     for i in range(len(metrics)):
#         pass
#     # compare the two metrics for the same thing

#     independents = 0
#     for i, interval in enumerate(intervals):
#         independent = True
#         for j, compare in enumerate(intervals):
#             if i != j:
#                 if interval.overlaps(compare):
#                     independent = False
#         if independent:
#             independents += 1

#     return independents

if __name__ == "__main__":
    import doctest

    # doctest.FAIL_FAST = True
    # doctest.NORMALIZE_WHITESPACE = True
    c = Context("SafeNetIoT")
    exp = Experiment(c, [State.IDLE], [Metric.MEAN], Classifier.Median, 180, 10)

    print("Running tests")

    # doctest.run_docstring_examples(Experiment.compute_confusion_matrix, globs=globals())
    doctest.testmod()
    print("All good")
