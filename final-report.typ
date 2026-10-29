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
#import "@preview/tblr:0.5.0": *
#import "@preview/zero:0.7.1": num, format-table, zi

#show: eestyle2

#let config = yaml("common.yml")

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

#set heading(supplement: "Chapter")


// TODO: criticise dataset, not specific on what devices
#align(center)[

  #image("assets/logo.pdf")

  #large([*SCHOOL OF ELECTRICAL ENGINEERING\
  AND TELECOMMUNICATIONS*])
  #v(1cm)
  #huge([*Profiling IoT Devices using Power \ Side Channel Techniques*])

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
  #heading([Abstract], outlined: false)
  
  #todo("update abstract")

]
#pagebreak()



#show outline.entry: it => link(
  it.element.location(),
  it.indented(it.prefix(), {if it.level == 1 {
    text(it.inner(), weight: "bold")} else {
      it.inner()
    }}),
)

#outline()
// #set heading(numbering: "Chapter", level: 1)
#show heading.where(level: 1): it => {

    set heading(numbering: "1", supplement: "Chapter")
    pagebreak()
    [Chapter #counter(heading).get().at(0) \ #it.body]
}

#set heading(numbering: "1.1")
#pagebreak()

= Introduction <intro>

#todo("Summary of chapters")

This thesis makes the following contributions: 

- A method of effectively classifying IoT devices by their power. Uses simple features and no machine-learning.
- A new dataset of IoT device power traces and a robust tooling for recording new data.

= Background <background>

The Internet of Things global market is valued at around \$860 billion USD; twice as big as Artificial Intelligence @InternetThingsIoT @ArtificialIntelligenceMarket. There are around 24 Billion active devices. Year-on-Year growth in both value and device population is around 11% @NumberConnectedIoT. 

Since Internet of Things is simply any network connected object, there is massive diversity in the devices. This heterogeneity presents a number of problems with managing these systems. A lack of regulation and push for cheap devices has left a vast attack surface of unmaintained and insecure devices. Botnets and widespread attacks have plagued IoT for many years @OfficePublicAffairs2024 @HackersTakeControl2024. 

Most recently, hackers were able to remotely attack supermarket fridges across Europe. @HundredsFrenchSupermarkets2026

One tool that can counter insecure devices is profiling. An external device can profile without any modification to the often resource constrained edge IoT nodes. A effective profile of a device can then allow for abnormalities to be detected and devices to be monitored. This has a range of applications across enterprise and the home.

Existing research on profiling IoT devices focuses on network traffic, which is a less direct indicator of internal state than power. I hypothesise that power may be more able to identify devices that send traffic intermittently. Power analysis and side channel attacks have long been used in cryptography to defeat the most secure encryption methods.

I've chosen to investigate power due to the following properties:

#emph("Universal"), every electronic device uses power. Network traffic is almost as universal, discounting air-gapped devices. Other side channels such as sound or 

#emph("Continuous"), unlike discrete network packets or flows power is continuous, the sum of the individual power consumed by every component of the device. These can each vary depending on the manufacturing differences and the current state of the device. Network traffic is sent intermittently and isn't directly tied to the internal state, some of this continuous information can be captured in timing variations.

#emph("Accessible"), non-invasive. Measuring externally powered devices doesn't require any modification to the device. There is the major limitation that battery powered devices would require software and potentially hardware modifications to report their power, hence they are not considered in thesis.

== Prior Work

Profiling of IoT Devices is a well studied field. Most work uses features derived from network traffic, but there is some use of power measurements. 

Side Channel Analysis has also been extensively studied. from it leaking sensitive data and internal state, rather than as a monitoring tool.

This thesis aims to explore both of those gaps in the literature.

=== Profiling and Fingerprinting

==== A Survey on IoT Profiling, Fingerprinting, and Identification

2022 paper, a comprehensive survey of IoT profiling @chenComprehensiveSurveySideChannel2025. They propose a taxonomy of IoT profiling techniques and features that have been seen across the literature. They identify 4 common domains of IoT profiling: Healthcare / Fitness, Smart Farming, Home Automation, and Smart City. They identify a architecture for profiling: data acquisition, feature extraction, data pre processing, modelling normal behaviour, and detection. There are also different types of profiling: device type detection, device instance detection, unseen device detection, and anomaly detection.

Of particular interest is the section on challenges and future directions. Feature extraction is considered the most challenging aspect of profiling, due to the demanding nature of existing approaches. There is no large public comprehensive dataset that is standardised, so papers often report high accuracy on a select group of devices. Machine learning models trained on these datasets may be inflexible to the true range of real-world devices.

Power is not is not mentioned as a feature, showing a gap in the research.

==== Manufacturer Usage Description

The IETF has proposed a standard for identifying end devices @learManufacturerUsageDescription2019a. It is intended to be used for access control. Under MUD each device communicates a URL, for a file that may be hosted  on the internet, a MUD controller can then enforce various properties on the device using software defined networking @WhyMUDManufacturer.

A 2026 paper, #emph("Role of Device Identification and Manufacturer Usage Description in IoT Security: A Survey") @mazharRoleDeviceIdentification2021 shows the current state of MUD, in particular a number of limitations that may be addressed using profiling. MUD has quite limited real world usage meaning that MUD and non-MUD devices will be mixed in networks for years to come. MUD is vulnerable to firmware modifications and malicious profiles before connection. In particular they highlight the usefulness of profiling and fingerprinting to account for these shortcomings. Some of these may be addressed in future versions of the standard.

==== Leveraging power consumption for anomaly detection on IoT devices in smart homes

This is the most similar paper to my thesis I've found @nimmyLeveragingPowerConsumption2023. Studied a mock IoT device consisting of a raspberry pi and attached camera, with the power measured through a desktop multimeter. They collect data in three scenarios, normal usage, the smart camera being DDoS attacked, and the camera compromised DDoSing another device. Simple power analysis shows almost doubled power consumption in both of the attack scenarios compared to normal. They then apply a range of machine learning techniques and report a 99.2% accuracy at detecting anomalies using a Dual-Feature Fusion Network. 

This paper shows that my approach has value but leaves many aspects unexplored. Since they only test one device there no comparison or evaluation of their method across additional devices. Additionally, when simple power analysis is sufficient to determine the presence of the attack, it is unjustified to jump to using machine learning a heuristic approach would suffice.

=== Side Channels

A side channel is any channel that conveys information other than the intended. For IoT devices the intended channel is the generally the network. Anything that changes in response to internal state can be side-channel. Most side-channels vary in response to the same stimuli, so information leakage to one side channel may indicate leakage to the rest @wangHertzbleedTurningPower2023

#figure(side-channels, caption: "Possible side-channels of a networked device, all of these have been exploited in various ways in the literature.")

In general, the more complicated or large a process is, the longer it takes and the more power it consumes. Doing nothing consumes less power than doing something. This has been a known attack since at least the 1990s, and was considered in the design of AES (Released in 2001) @chariSoundApproachesCounteract1999. Protecting against side channel attacks is up to both the design of the algorithm and the hardware implementation. Mitigations such as constant-time computing and data-masking, but these are likely to only be applied to directly security critical subsystems, due to their performance overheads.

Power analysis has two major approaches @chatterjeeHardwareSecurityConnected2022: 

#emph("Simple") where single traces are compared against each other, this is effective at detecting a large difference in power, e.g if a fan is switched on or off. 

#emph("Differential"), where many samples of traces in different states are compared. Even very small differences in power can be observed. 

=== MCSA / ESA


= Measuring Power of IoT Devices <data>

In order to evaluate and develop fingerprinting and profiling methods for IoT devices, datasets are required. My work uses two different ones: The SafeNetIoT Dataset @SafeNetIoTPowerIDS2026 developed for Zhou et al @zhouCatchingHackersWatching2026a and a new dataset created for this thesis.

Both use the same method of measurement, a consumer grade Wi-Fi Socket, the Tapo P110. This allows for easy recording of the power of many devices. However there it is quite limited in fidelity. The maximum measurement frequency is 1Hz and the resolution seems to be 1 mW (at least this is resolution that data is reported at, additional testing would be required to verify this). There is no technical datasheet available and access is through an undocumented internal api. Additionally it has no accessible internal memory and must be polled to obtain a measurement. 

== SafeNetIoT Dataset

The data from Zhou et al @zhouCatchingHackersWatching2026a, is publicly available on Github @SafeNetIoTPowerIDS2026. 

They measured the power at 1 Hz of 33 different IoT devices using a Tapo P110 Smart Plug. They group the devices into general categories based on the type and functionality. I've only examined the benign idle and active scenarios as these represent typical operation of the devices.

#figure(output("safenetiot"), caption: "Devices in SafeNetIoT dataset by category")

The amount of available data is small with each trace lasting around 40 minutes and there is only 1 trace per situation. After splitting the data into training and setting a baseline of the device this leaves very little unknown data for verification. 

A number of more minor limitations of this dataset:

- Data is recorded only at 1 Hz, which is well below common supply frequencies, so modulation of this frequency when internal components of will not be detectable. This means that frequency analysis techniques are unlikely to be useful. The features would likely be strong identifiers as used in 
- Exact device models or software versions were not recorded. A different model of the "same" device may have different power usage characteristics. 
- The idle data for the Echo Dot 3 is truncated to 1 minute of data, hence I haven't considered it in my work.
- Each device was recorded for a different length of time. To have a consistent dataset I've truncated the data so that each device has the same length of samples as the shortest device in the dataset. With 25 minutes of training data this leaves 12 minutes of unseen data.




== My Dataset

Attempt to supplement and address some of the limitations of the SafeNetIoT. Adding replication to Zhou et al @zhouCatchingHackersWatching2026a

The UNSW EET IoT Lab has a library of many IoT devices. I chose to study tho. The main improvement over the dataset is the length of data available. This will improve the quality and reliability of results from this.

Just like in the SafeNetIoT dataset, power is measured at 1 Hz using a Tapo P110. 

#figure(measurement, caption: [The measurement setup, solid lines are a direct connection, wavy lines are Wi-Fi])

Data is obtained by the server, running on a Raxda Rock Pi 4 and compiled in to CSV files. The data collection is robust to changes in the network. If the connection to the Tapo 




The IoT Lab is not a completely controlled environment, the network is open and connected to the internet. This will introduce some noise into the data, but more closely reflects a real-world environment
Since the focus of this experiment is on retrieving a lot of data, 

Another thesis student is conducting scans of the network, so we will coordinate to annotate data. This may produce high power consumption of some devices,  but not the same as the device itself being active.





#figure(table(
  columns: 4,
  [Name], [Model Number], [Category], [Connectivity],
  [Amazon Echo Show 5], [C76N8S], [Audio], [WiFi],
  [Google Nest Hub (2nd Gen)], [GUIK2], [Audio], [WiFi],
  [Apple Home Pod Mini], [A2374], [Audio], [WiFi],
  [EzViz Camera], [CS-C6N], [Camera], [WiFi],
  [Aoetec Camera], [CP-AEOHUBV3AN], [Camera], [Ethernet],
  [D-Link Camera], [DC-8330LH], [Camera], [WiFi]
  // [Awair], [Audio], [], [],
  // [Netaimo x3], [?], [], [],
  // [Amazon Echo x2], [Audio], [], [],
  // [Triby], [Audio], [], [],
  // [Samsung Smart Cam], [Camera], [], [],
  // [Withings ?], [Camera], [], [],
  // [Pixstar], [Appliance], [], [],
  // [Google Guik2], [Audio], [], [],
  // [Nondescript screen with wall hangers on back], [?], [], [],
  // [Aqara zigee], [], [], [],
  // [unknown smart bulb], [lights], [], [],
  // [grd connect bulb], [lights], [], [],
  // [apple homepod], [smart home], [], [],
  // [enviz camera], [camera], [], [],
  // [dlink], [camera], [], [],
  // [aeotec zigbee], [], [], [],
  // [vtech], [camera], [], [],
  // [tapo wireless thingy x2], [], [], [],
  // [deebot], [applicance], [], [],
  // [vtech], [camera monitor], [], [],
  // [hikvision], [camera], [], [],
  // [bulb x8 various], [lights], [], [],
  // [interlogix], [camera], [], [],
  // [laserco], [camera], [], [],
  // [Tapo smart hub], [], [], [],
  // [Tapo smart plug], [], [], [],
), caption: [Devices in my dataset. Of the devices in both datasets, only the Apple Home Pod is common. However since there is no exact model number it may be a different model with a similar name.])

#todo([Record software revisions])




= Fingerprinting and Profiling IoT Devices <results>

The chapter details a method to classify devices solely based on their power data. Performance is evaluated using the SafeNetIoT dataset and my dataset.

== Early Observations

With the SafeNetIoT Dataset, I first investigated some the raw time series data.

#todo([example of time series / or all together?])

Many devices are at distinct levels. Under the assumption that once in a certain state the power is consistent, taking the mean of will measure this

== Method for classifying IoT Power Data by Device

Based on the observations made above, the mean power of devices is quite distinct. 

#todo("More detail in diagram, show both training and testing")

#figure(
    process
  , caption: [Method overview]
)

#todo("Why windows")

Each device's data is split into two sections: 25 minutes of training data to extra classes and 12 minutes of unseen data for evaluation. The data is further split into windows of width $w$ seconds with a gap of $s$ seconds between left edges of windows. 

For each window in the training data, a metric is evaluated. The median value across all windows is recorded as the unique signature of each device. Currently the only metric is the mean. In the future this could be any characteristic.

#todo("graphic showing classification by distance")

For each window in the unseen data, we classify by minimising the distance to the medians for each device computed earlier. This is quite a naive approach and will not work when combining multiple metrics as median only makes sense in 1 dimension. 

To evaluate the performance of the classification we compute a confusion matrix, this shows how often a device is classified as each other device. If all classes were classified correctly there would be a fully diagonal line. From this we evaluate the precision and F1 score for each class.

 For the overall performance of a test we evaluate the macro average F1 score, this is simply the unweighted mean of all F1 scores of each class.

== Determining appropriate values of window parameters

The data windowing is controlled by two parameters, $w$ and $s$. These effect the performance of the metrics,  $w$ was varied from 10 to 600, at a resolution of 10 seconds. 600 seconds = 10 minutes was chosen as the upper limit because with our split there is only 10 minutes of training data. A very long window also increases the latency of the classification when operating in a real time environment. Preliminary results showed that $s$ had a minor effect compared to $w$, so only a few values.


#todo("Combine plots into 1?, memoise ")

#figure(image("assets/w_s_idle_1.pdf"), caption: [Macro Average F1 score for all devices whilst varying $w$ and $s$ window parameters on IDLE data classified by $mu$]) <w_s_idle>


#figure(image("assets/w_s_active_1.pdf"), caption: [F1 score performance whilst varying $w$ and $s$ window parameters on ACTIVE data classified by $mu$]) <w_s_active>

From @w_s_idle and @w_s_active, we can observe that the performance is the worst if $w < 100$. After that performance slowly degrades as w increases. The impact of s is minor, so choose the largest value for computational speed. Choose to fix $w = #config.w$ and $s = #config.s$ for the rest of these results.

There is a lot of variation in performance, just seems that there isn't enough data or there are unaccounted time variation. 

== Classification by $mu$

Using the fixed values of w and s above, we compute the confusion matrices. A confusion matrix shows how often a window in the training data is correctly classified. This is applied across both the idle and active datasets. 

From the confusion matrix two overall measures are calculated, the Macro Average F1 score and the number of devices with high precision. The first is the equally weighted mean (as opposed to a weighted mean which could be used if information about the prevalence of the means was know) of the F1 scores. The F1 score is the . 
#figure(image("assets/confusion-matrix-idle-150-100-mean-Median.pdf", width: 120%), caption: [Confusion Matrix for Idle data. Metric: mean and classification by median]) <idle180_10>

#figure(image("assets/confusion-matrix-active-150-100-mean-Median.pdf", width: 120%), caption: [Confusion Matrix for Active data. Metric: mean and classification by median], kind: table) <active180_10>

#figure(output("confusion matrix", item: 0), caption: [Macro Average F1 Scores compared for Idle and Active datasets, windowed at w=#config.w, s=#config.s and classified using mean metric and distance from median]) <macroavg>

//@macroavg 

These results are encouraging, with many devices able to be correctly classified. Let's investigate a particularly problematic case the Sonos speaker, it performs particularly poorly across both the active and idle datasets.

#figure(output("confused with", item: 0), caption: [Sonos Speaker w window results with the Echo Spot 5 it is confused with in the Idle state by $mu$])

#figure(output("confused with", item: 1), caption: [Sonos Speaker Compared with the by $mu$])

Comparing the two states, the reasons for the differing performance is clear, the idle testing results are tightly clustered. The active is not as tightly clustered and is confused with a number of other devices. An additional feature or improvement will be need to correctly classify it.

== Classification by $mu$ and $sigma$

$sigma$ or standard deviation measures how spread out a distribution is. On it's own it carries no information about the steady state value, When combined with $mu$ it will more thoroughly classify a distribution.

Building on the same problematic Sonos device in the previous section, it's $sigma$ plotted: 

#figure(output("confused with", item: 2), caption: [Sonos Speaker w window results with the Echo Spot 5 it is confused with in the Idle state by $sigma$]) <sonos_std>

#figure(output("confused with", item: 3), caption: [Sonos Speaker Compared with the other devices confused with in the Active state by $sigma$])

@sonos_std shows that the Sonos Speaker in the idle state is not confused with the Echo Dot 5 when using $sigma$ as the metric. However it is confused with many other devices. Importantly the sets of confused devices are distinct from each other, so if the metrics are combined the performance should improve


#figure(image("assets/confusion-matrix-idle-150-100-mean-std-Median.pdf"), caption: [Confusion Matrix for Idle  data windowed with w=#config.w, s=#config.s. Metric: $mu$ and $sigma$ and classification by median]) <mu_sigma_idle>

#figure(image("assets/confusion-matrix-active-150-100-mean-std-Median.pdf"), caption: [Confusion Matrix for Idle  data windowed with w=#config.w, s=#config.s. Metric: $mu$ and $sigma$ and classification by median]) <mu_sigma_active>

In @mu_sigma_idle we observe that the performance of the Sonos speaker is greatly improved under idle conditions by the introduction of the $sigma$ metric.

== Summary of Results

#figure(
    image("assets/table_summary.pdf"),
caption: [Comparison of F1 scores between idle and active datasets and either $mu$ only or $mu$ and $sigma$ together. All classifications are by median and w = #config.w, s = #config.s.], kind: table
  )
  <comparison>

@comparison compares the performances of all devices in the both the idle and active datasets. 

shows that the performance is better on the active dataset. This is due to there being more distinct levels of active power usage. In the idle dataset, the spread of power is lower so devices are more likely to overlap.

- The overall performance is better in the active mode, but individual devices that perform well in idle do not necessarily perform as well in active. 

- The performance can degrade by adding the additional metric (e.g Google Nest in Idle), I need to investigate further, but this can happen. #todo(["Why can performance degrade"])

- The worst devices are: Honeywell Thermostat, Weekett Kettle, Antela Light, Leopro Light, Echo Spot 5 Speaker



== Combining Active and Idle

So far we've known that the state of data going in, a harder problem that is closer to a potential real-world problem is determining the state of an unknown device. 

By classifying the testing data using both the active and idle models. The state is determined by first classifying as a certain device in a certain state and then discarding the state.

#figure(caption: [Success at classifying to correct state], image("assets/table_both.pdf"), kind: table)

== Applying to My Dataset

As discussed above, the reliability of results from the SafeNetIoT dataset is limited, replicate on the dataset.

#todo("any changes throughout the day? / long term trends. Check validity, are days largely self similar?")

= Conclusion

== Future Work

- attacks, SafeNetIoT code to replicate
- combine with network
- disaggregation @raikerEnergyDisaggregationUsing2021
- more sophisticated measurement

= Bibliography

#bibliography("Thesis.bib", title: none)