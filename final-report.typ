// Style: 
// training -> model
// long captions, can be used isolated
// RQ in text

#import "@preview/callisto:0.3.0"
#import "eestyle2.typ": *
#import "util.typ": *
#import "@preview/cetz:0.5.2"
#import "@preview/numty:0.1.0" as nt
#import "diagrams.typ": *


#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("analysis.ipynb"),
)

#let todo(content) = {
  [TODO: *#content*]
}

#show figure: set figure.caption(position: bottom)


#show figure.where(
  kind: table
): set figure.caption(position: top)

#show outline.entry: it => link(
  it.element.location(),
  it.indented(it.prefix(), it.inner()),
)

// Bold all table titles and right align non index
#show table.cell: cell => {
    let styled_cell = cell
    if cell.x != 0 {
      styled_cell = align(right, styled_cell)
    } else {
      styled_cell = align(left, styled_cell)
    }
    if cell.y == 0 {
        styled_cell = [*#styled_cell*]
    }
    styled_cell
  }

#let look-at-in-meeting(h) = {
    heading(level: 1)[$arrow$ #h]
}

#show: eestyle2


// TODO: criticise dataset, not specific on what devices
#align(center)[

  #image("assets/logo.pdf")

  #large([*SCHOOL OF ELECTRICAL ENGINEERING\
  AND TELECOMMUNICATIONS*])
  #v(1cm)
  #huge([*Final Report*])

  #Large([by])
  #v(-0.2cm)
  #huge([Jack Robbers])
  #v(-0.2cm)
  #Large([Student ID: z5263682])
  #v(0.5cm)

  #Large([Thesis submitted as a requirement for the degree \ Bachelor of Engineering (Electrical Engineering)])
]

#align(center + bottom)[
  #Large(
    [Submitted: #datetime.today().display("[month repr:long] [day] [year]") \ Supervisor: A/Prof Hassan Habibi Gharakheili],
  )
]

#pagebreak()
#counter(page).update(1)
#set page(numbering: "1.")

#align(center + horizon)[
  *Abstract*
  
  #todo("update abstract")

  Internet of Things is a growing industry, with a huge range of devices now populating networks across industrial and home deployments. Profiling of these devices is necessary for attack detection and enforcing that they are well behaved. Previous literature has focused on using network traffic for this, I propose a new approach borrowing the technique of power analysis from cryptography. I present preliminary results showing the promise of this power data and plan for the rest of this Thesis.

]


#pagebreak()

= Acknowledgements

#todo("formalise")

I'd like to acknowledge the understanding and encouraging help of my supervisor, Hassan Habibi Gharakheili.


My parents, housemates, and friends for support. Time to ride bikes!

= Abbreviations

#let abbreviate(defs) = {
  grid(
    columns: (40pt, 1fr), row-gutter: 2%,
    ..for def in defs.sorted() {
      (strong(def.at(0)), def.at(1))
    }
  )
}

#abbreviate((
  ("DDOS", "Direct Denial of Service"),
  ("IoT", "Internet of Things"),
  ("ICMP", "Internet Control Message Protocol"),
  ("AES", "Advanced Encryption Standard"),
  ("IETF", "Internet Engineering Task Force"),
  ("MUD", "Manufacturer Usage Description"),
))

#outline()
#set heading(numbering: "1.")

= Introduction

== Background

The Internet of Things global market is valued at around \$860 billion USD; twice as big as Artificial Intelligence @InternetThingsIoT @ArtificialIntelligenceMarket. There are around 24 Billion active devices. Year-on-Year growth in both value and device population is around 11% @NumberConnectedIoT. 

Since Internet of Things is simply any network connected object, there is massive diversity in the devices. This heterogeneity presents a number of problems with managing these systems. A lack of regulation and push for cheap devices has left a vast attack surface of unmaintained and insecure devices. Botnets and widespread attacks have plagued IoT for many years @OfficePublicAffairs2024 @HackersTakeControl2024. 

One tool that can counter insecure devices is profiling. An external device can profile without any modification to the often resource constrained edge IoT nodes. A effective profile of a device can then allow for abnormalities to be detected and devices to be monitored. This has a range of applications across enterprise and the home.

Existing research on profiling IoT devices focuses on network traffic, which is a less direct indicator of internal state than power. I hypothesise that power may be more able to identify devices that send traffic intermittently. Power analysis and side channel attacks have long been used in cryptography to defeat the most secure encryption methods.

== Thesis Aims

My thesis has two major aims:

+ Produce a dataset of the power usage and network traffic of a range of IoT devices. 

+ Investigate and evaluate methods for profiling IoT devices using power data.

I've chosen to investigate power due to the following properties:

#emph("Universal"), every IoT device uses power. A profiling solution will work on all devices. Network traffic also has this property, but some possible other channels like temperature do not.

#emph("Continuous"), unlike discrete network packets or flows power is continuous, the sum of the individual power consumed by every component of the device. These can each vary depending on the manufacturing differences and the current state of the device. Network traffic is sent intermittently and isn't directly tied to the internal state, some of this continuous information can be captured in timing variations.

#emph("Accessible"), non-invasive. Measuring externally powered devices doesn't require any modification to the device. There is the major limitation that battery powered devices would require software and potentially hardware modifications to report their power, hence they are not considered in thesis.

= Literature Review

== Profiling and Fingerprinting

=== A Survey on IoT Profiling, Fingerprinting, and Identification

2022 paper, a comprehensive survey of IoT profiling @chenComprehensiveSurveySideChannel2025. They propose a taxonomy of IoT profiling techniques and features that have been seen across the literature. They identify 4 common domains of IoT profiling: Healthcare / Fitness, Smart Farming, Home Automation, and Smart City. They identify a architecture for profiling: data acquisition, feature extraction, data pre processing, modelling normal behaviour, and detection. There are also different types of profiling: device type detection, device instance detection, unseen device detection, and anomaly detection.

Of particular interest is the section on challenges and future directions. Feature extraction is considered the most challenging aspect of profiling, due to the demanding nature of existing approaches. There is no large public comprehensive dataset that is standardised, so papers often report high accuracy on a select group of devices. Machine learning models trained on these datasets may be inflexible to the true range of real-world devices.

Power is not is not mentioned as a feature, showing a gap in the research.

=== Manufacturer Usage Description

The IETF has proposed a standard for identifying end devices @learManufacturerUsageDescription2019a. It is intended to be used for access control. Under MUD each device communicates a URL, for a file that may be hosted  on the internet, a MUD controller can then enforce various properties on the device using software defined networking @WhyMUDManufacturer.

A 2026 paper, #emph("Role of Device Identification and Manufacturer Usage Description in IoT Security: A Survey") @mazharRoleDeviceIdentification2021 shows the current state of MUD, in particular a number of limitations that may be addressed using profiling. MUD has quite limited real world usage meaning that MUD and non-MUD devices will be mixed in networks for years to come. MUD is vulnerable to firmware modifications and malicious profiles before connection. In particular they highlight the usefulness of profiling and fingerprinting to account for these shortcomings. Some of these may be addressed in future versions of the standard.

=== Leveraging power consumption for anomaly detection on IoT devices in smart homes

This is the most similar paper to my thesis I've found @nimmyLeveragingPowerConsumption2023. Studied a mock IoT device consisting of a raspberry pi and attached camera, with the power measured through a desktop multimeter. They collect data in three scenarios, normal usage, the smart camera being DDoS attacked, and the camera compromised DDoSing another device. Simple power analysis shows almost doubled power consumption in both of the attack scenarios compared to normal. They then apply a range of machine learning techniques and report a 99.2% accuracy at detecting anomalies using a Dual-Feature Fusion Network. 

This paper shows that my approach has value but leaves many aspects unexplored. Since they only test one device there no comparison or evaluation of their method across additional devices. Additionally, when simple power analysis is sufficient to determine the presence of the attack, it is unjustified to jump to using machine learning a heuristic approach would suffice.

== Side Channels

A side channel is any channel that conveys information other than the intended. For IoT devices the intended channel is the generally the network. Anything that changes in response to internal state can be side-channel. Most side-channels vary in response to the same stimuli, so information leakage to one side channel may indicate leakage to the rest @wangHertzbleedTurningPower2023

#figure(side-channels, caption: "Diagram showing potential side-channels of a networked device, all of these have been exploited in various ways in the literature.")

In general, the more complicated or large a process is, the longer it takes and the more power it consumes. Doing nothing consumes less power than doing something. This has been a known attack since at least the 1990s, and was considered in the design of AES (Released in 2001) @chariSoundApproachesCounteract1999. Protecting against side channel attacks is up to both the design of the algorithm and the hardware implementation. Mitigations such as constant-time computing and data-masking, but these are likely to only be applied to directly security critical subsystems, due to their performance overheads.

Power analysis has two major approaches @chatterjeeHardwareSecurityConnected2022: 

#emph("Simple") where single traces are compared against each other, this is effective at detecting a large difference in power, e.g if a fan is switched on or off. 

#emph("Differential"), where many samples of traces in different states are compared. Even very small differences in power can be observed. 

== Dataset

The main paper similar to my work @zhouCatchingHackersWatching2026, made their data publicly available @SafeNetIoTPowerIDS2026. They recorded 33 different IoT devices across 5 categories (lights, audio, cameras, tv, appliances) and under a range of conditions both benign and hostile. So far I've only considered the idle scenario in my work, in order to determine the viability of a heuristic technique. Each trace is the power data measured using a smart plug at 1 Hz for around 40 minutes.

There are a number of limitations with this dataset:
- The idle data for the Echo Dot 3 is truncated to 1 minute of data, hence I haven't considered it in my work.
- Exact device models or hardware revisions were not recorded. A different model of the same device may have different power usage characteristics. 
- Each device was recorded for a different length of time. To have a consistent dataset I've truncated the data so that each device has the same length of samples as the shortest device in the dataset. With 25 minutes of training data this leaves 12 minutes of unseen data.
- The amount of available data is relatively small. I will replicate my results on my own dataset to address this.


== Current Method

#todo("Two paths here / two diagrams?")

#figure(
    process
  , caption: [Method overview]
)

Each device's data is split into two sections: 25 minutes of training data to extra classes and 12 minutes of unseen data for evaluation. The data is further split into windows of width $w$ seconds with a gap of $s$ seconds between left edges of windows. 

For each window in the training data, a metric is evaluated. The median value across all windows is recorded as the unique signature of each device. Currently the only metric is the mean. In the future this could be any characteristic.

For each window in the unseen data, we classify by minimising the distance to the medians for each device computed earlier. This is quite a naive approach and will not work when combining multiple metrics as median only makes sense in 1 dimension. 

To evaluate the performance of the classification we compute a confusion matrix, this shows how often a device is classified as each other device. If all classes were classified correctly there would be a fully diagonal line. From this we evaluate the precision and F1 score for each class.

 For the overall performance of a test we evaluate the macro average F1 score, this is simply the unweighted mean of all F1 scores of each class.



== Idle vs Active


#figure(image("assets/confusion-matrix-idle-180-10.pdf", width: 120%), caption: [Confusion Matrix for Idle data windowed with w=180, s=10. Metric: mean and classification by median]) <idle180_10>

#figure(image("assets/confusion-matrix-active-180-10.pdf", width: 120%), caption: [Confusion Matrix for Active  data windowed with w=180, s=10. Metric: mean and classification by median]) <active180_10>

#figure(render_table(output("confusion matrix", item: 6)), caption: [Macro Average F1 Scores compared for Idle and Active datasets, windowed at w=180, s=10 and classified using mean metric and distance from median]) <macroavg>

@macroavg shows that the performance is better on the active dataset. This is due to there being more distinct levels of active power usage. In the idle dataset, the spread of power is lower so devices are more likely to overlap.

== Effect of window size and shift

== $mu$ $sigma$ by 2d median

Classify by both metrics using 2d median. 

Naive technique, feels like it introduces some error, but all the devices have it? They don't actually overlap

#figure(image("assets/confusion-matrix-idle-300-120-mean-std-Median.pdf"), caption: [Confusion Matrix for Idle  data windowed with w=300, s=120. Metric: $mu$ and $sigma$ and classification by median])

#figure(image("assets/confusion-matrix-active-300-120-mean-std-Median.pdf"), caption: [Confusion Matrix for Active  data windowed with w=300, s=120. Metric: $mu$ and $sigma$ and classification by median])

// == By first harmonic

== Centroid Classifier

== Summary Table / Problematic Devices
 
#[
  #show table.cell.where(body: [1.000]): it => {
    highlight(fill: green)[#it]
  }

   #show table.cell.where(y: 33): it => {
    [*#it*]
  }

  #figure(
    render_table(output("summary", item: 0)), caption: [Comparison of F1 scores between idle and active datasets and either $mu$ only or $mu$ and $sigma$ together. All classifications are by median and w = 300, s = 120. Sorted by the performance in Idle by $mu$] 
  )
  <comparison>
  
]

@comparison compares the performances of all devices in the both the idle and active datasets. 

- The overall performance is better in the active mode, but individual devices that perform well in idle do not necessarily perform as well in active. 

- The performance can degrade by adding the additional metric (e.g Google Nest in Idle), I need to investigate further, but this can happen.

- The worst devices are: Honeywell Thermostat, Weekett Kettle, Antella Light, Leopro Light, Echo Spot 5 Speaker


== Lab

#table(
  columns: 4,
  [Name], [Category], [Connectivity], [Audio],
  [Awair], [Audio], [], [],
  [Netaimo x3], [?], [], [],
  [Amazon Echo x2], [Audio], [], [],
  [Triby], [Audio], [], [],
  [Google Home], [Audio], [], [],
  [Samsung Smart Cam], [Camera], [], [],
  [Withings ?], [Camera], [], [],
  [Pixstar], [Appliance], [], [],
  [Google Guik2], [Audio], [], [],
  [Amazon Echo Show], [], [], [],
  [Nondescript screen with wall hangers on back], [?], [], [],
  [Aqara zigee], [], [], [],
  [unknown smart bulb], [lights], [], [],
  [grd connect bulb], [lights], [], [],
  [apple homepod], [smart home], [], [],
  [enviz camera], [camera], [], [],
  [dlink], [camera], [], [],
  [aeotec zigbee], [], [], [],
  [vtech], [camera], [], [],
  [tapo wireless thingy x2], [], [], [],
  [deebot], [applicance], [], [],
  [vtech], [camera monitor], [], [],
  [hikvision], [camera], [], [],
  [bulb x8 various], [lights], [], [],
  [interlogix], [camera], [], [],
  [laserco], [camera], [], [],
  [Tapo smart hub], [], [], [],
  [Tapo smart plug], [], [], [],
)


= References

#bibliography("Thesis.bib", title: none)