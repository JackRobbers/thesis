#import "@preview/callisto:0.3.0"
#import "@preview/timeliney:0.4.0"
#import "eestyle2.typ": *
#import "util.typ": *
#import "@preview/cetz:0.4.2"
#import "@preview/numty:0.1.0" as nt



#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("analysis.ipynb"),
)

#show figure: set figure.caption(position: bottom)


#show figure.where(
  kind: table
): set figure.caption(position: top)



#show: eestyle2

// TODO: criticise dataset, not specific on what devices
#align(center)[

  #image("assets/logo.pdf")

  #large([*SCHOOL OF ELECTRICAL ENGINEERING\
  AND TELECOMMUNICATIONS*])
  #v(1cm)
  #huge([*Progress Report*])

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
#outline()
#pagebreak()


#set heading(numbering: "1.")

= Progress

== Dataset

The main paper similar to my work @zhouCatchingHackersWatching2026, made their data publicly available @SafeNetIoTPowerIDS2026. They recorded 33 different IoT devices across 5 categories (lights, audio, cameras, tv, appliances) and under a range of conditions both benign and hostile. So far I've only considered the idle scenario in my work, in order to determine the viability of a heuristic technique. Each trace is the power data measured using a smart plug at 1 Hz for around 40 minutes.

There are a number of limitations with this dataset:
- The idle data for the Echo Dot 3 is truncated to 1 minute of data, hence I haven't considered it in my work.
- Exact device models or hardware revisions were not recorded. A different model of the "same" device may have different power usage characteristics 
- Each device was recorded for a different length of time, varying but up to a few minutes. To have a consistent dataset I've truncated the data so that each device has the same length of samples as the shortest device in the dataset. With 25 minutes of training data this leaves 12 minutes of unseen data.
- The amount of available data is relatively small. I hope to replicate my results on my own dataset.


== Current Method

Each devices data is split into two sections: 25 minutes of training data to extra classes and 12 minutes of unseen data for evaluation. The data is further split into windows of width $w$ seconds with a gap of $s$ seconds between left edges of windows. A metric is then evaluated on each of the windows.

For each window in the unseen data, we classify by minimising the distance to the median of the means from training. This is quite a naive approach and will not work when combining multiple metrics as median only makes sense in 1 dimension. 

To evaluate the performance of the classification we compute a confusion matrix, this shows how often a device is classified as each other device. If all classes were classified correctly there would be a fully diagonal line. From this we evaluate the precision and F1 score for each class.

 For the overall performance of a test we evaluate the macro average F1 score, this is simply the unweighted mean of all F1 scores of each class.

== Results

#[
  #set image(width: 120%)
  #set align(center)
  // #output("plot1")
  #figure(image("assets/confusion-matrix-idle-180-10.pdf"), caption: [Confusion Matrix for $mu$ with w=180, s=10])
]

#[
  #show table.cell: cell => {
    if cell.x == 0 {
      align(left)[#cell]
    } else {
      cell
    }
  }
 #figure(render_table(output("confusion matrix", item: 1)), caption: [Performance of device identification based on 3-min window of power usage during idle mode (sorted by precision)])
]
Considering a 95% threshold, 20/32 devices will be classified correctly. This is an encouraging result for such a simple method. It is likely

However there are a number of devices that are poorly classified. In particular the LIFX Light is never classified correctly. @lifx shows the training and unseen data for the Toshiba TV it is classified as, with the median of the training as a vertical line. All of the unseen data is much closer to the Toshiba training's median. 

#figure(output("confused with", item: 0), caption: [LIFX vs Toshiba TV]) <lifx>

// #figure(output("confused with", item: 1), caption: [Weekett Kettle vs B]) <weekett>

// Looking at another poorly classified device the apple TV in @weekett. 

The median isn't very robust. There also could be time dependent effects unaccounted for in the data.

=== Effect of varying window size and shift
#[
  #show table.cell: cell => {
    if (cell.x == 0 or cell.y == 0) {
      cell
    } else {

    if (cell.x > 1 and cell.x < 5 and cell.y > 0) {
      text(fill: green)[#cell]
    } else {
      text(fill: red)[#cell]
    }
    }
  }
#figure(render_table(output("results", item: 0)), caption: "Macro Average F1 score for a range of window sizes and shifts") <ws>
]
@ws show that the amount of time between the windows $s$ does not meaningfully impact the performance, choosing a larger value will save computation time and space. However varying the window size $w$ does impact the performance, if it is too large or too small. I hypothesise this is due to a small window producing too much variance in means so the median is thrown off and the that a large window averages more data, producing a result that can be more confidently wrong.


#[  
  #set image(width: 120%)
  #set align(center)
  // #output("plot1")
  #figure(image("assets/confusion-matrix-idle-600-60.pdf"), caption: [Confusion Matrix for $mu$ with w=600, s=60]) <confusion-matrix-idle-600-60>
] 

@confusion-matrix-idle-600-60 Confusion matrix showing degraded performance with increased window size, the classes are more confident on their wrong values.


=== Outlier removal
#[
  #show table.cell: cell => {
    if (cell.x == 0 or cell.y == 0) {
      cell
    } else {

    if (cell.x > 1 and cell.x < 5 and cell.y > 0) {
      text(fill: green)[#cell]
    } else {
      text(fill: red)[#cell]
    }
    }
  }
#figure(render_table(output("results", item: 2)), caption: [Varying  w and s for $mu$ but with outlier detection])
]
I applied outlier removal of anything beyond 2$sigma$ (there was noting outside of 3$sigma$), and the overall performance was largely unchanged. I think the lack of outliers is because the mean should be a random variable and hence follow a normal distribution. Outliers could come from non random processes that affect the device's power. 





= Reflection

So far, I have not produced quality work and am unhappy with my progress. I want to finish this term so need to apply strategies to change this. 
There are factors both in and out of my control. I've had some unfortunate health issues but also have not put in the time commitment need to complete an honours thesis. I can only control certain things and need to learn to work with my current abilities.

During term 1 I completed thesis A. Early in the term I was reading papers each week and familiarising myself with the field. For the report, I hadn't done enough reading, but also didn't get everything into the report that I'd read about. I really struggle to make myself sit down and engage with the work deeply.

During term 2, I was initially working on Thesis B with a similar rate to thesis A. The goal was to both produce a dataset and a method for classifying data. I forgot to enrol in Thesis B, not noticing until week 5 when this part B progress report should have been due. I clearly was not a very engaged student. Later in the term my sleep got really bad and I was needing to take 2 naps every day. I did hardly anything from week 6-10. I sought medical attention for this and began to admit to myself that I was really struggling. I got lots of tests and discovered a physical cause of some my issues and was able to sleep better.

This is something I've struggled with throughout the later half of my degree but hasn't been as big of issue until a year-long project like this. I find myself to be very "momentum" based worker. Actually starting the work is often the hard part for me, once I start writing I can often concentrate for many hours. But I will procrastinate for a whole day before starting. It's self destructive. I get comfortable and coast along. I hasn't effectively used the resources at my disposal.

In the thesis meeting prior to this report, I came with a confusion matrix that was not working because I'd broken it just beforehand. I was flustered and couldn't even read that graph correctly. This is obviously unacceptable and served as a wake up call. I committed to really spending the next few days doing my best work and submitting a draft of the thesis B report . Friday and Saturday were good, cleaning up the codebase and implementing the confusion matrix. Sunday I faltered, not getting any work done. On Monday, I didn't get anything done until 5pm but then had some good sessions completing the reflection and planning sections. On Tuesday I inserted all of my results and commentary. I hope through this report I've somewhat shown that I can complete this thesis. I've attempted to be genuinely introspective and honest with myself.

This thesis has taught me many things about myself and honestly is the most challenging thing I've ever done. Steady progress is more effective than a burst. Also the setting and time around work is so important. I find the problems overwhelming, with so many directions to go in and so many things that I don't know

I have 7 weeks remaining in this thesis, and will take the following actions to ensure that I'm successful:

- Finalise results by the night before the meeting. With the morning before the meeting for writing up observations and literature review. Coming to the meeting unprepared is a waste of both our time. 
- Pomodoro technique / Time tracking. Apply study techniques to better use my time, getting started as early as I can in the day, and just getting something done will often give me lots of momentum. I've set myself a goal to complete on at least 20 hours of work on my thesis per week. This is averaged across days. I am also working \~10 hours a week. I will also use weekends if needed but aim to keep these free to recharge. 
- Parallel working, I reached out to and spent a few sessions working next to a friend.  
- Therapy, I've started seeing a therapist and we are working on techniques for getting things done and sleep.

I'd like to apologise to Hassan for, I've likely been quiet a frustrating student to deal with and thank him for his understanding so far. In writing this report and in particular this reflection I hope to demonstrate that I can complete this.


= Plan

I plan to spend October (weeks 4-8) finalising the practical component of my thesis including the data collection and method for profiling devices. November will be dedicated to the poster and report. 

== Gantt Chart

#text(size: 12pt, timeliney.timeline(
  show-grid: true,
  {
    import timeliney: *

    let my-task(name, from, to) = {
      task(
          name,
          (from: from, to: to),
          style: (stroke: 13pt + black),
        )
    }

    let my-milestone(content, at) = {
      milestone(
      at: at,
      style: (stroke: (dash: "dashed")),
      align(center, content)
    )
    }
    headerline(group(([Week], 8)))
    headerline(
      group(..range(2, 10).map(n => strong(str(n + 1)))),
    )
  
    taskgroup(
      title: [*Thesis B*],
      style: (stroke: 0pt + black),
      {
        my-task("Progress Report", 0, .8)
        my-task("Data Collection", 1, 4)
        my-task("Validate method on own data", 4, 5)
        my-task("Add additional metrics", 1, 3)
        my-task("better classification", 3, 5)
        my-task("Executive Summary", 6, 7)
      // TODO break this down more
      },
    )


    taskgroup(title: [*Thesis C*],  style: (stroke: 0pt + black), {
      my-task("Report C", 5, 7.8)
      my-task("Poster", 5, 6.6)
    })
    my-milestone([Progress Report Due], .8)
    my-milestone([Poster Day], 7)
    my-milestone([Final Due Date], 7.8)
  }
))

== Dataset

I had originally intended to produce a more complicate dataset. Just attempting to replicate the idle results, and using multiple. Restrict to number of devices and just do idle. Considering active usage is more complicated since it requires either genuine interaction with the device or automation of interaction which is different for each device. 

I will collect data on 10 devices with long overnight traces.

== Method Improvements

- Use more complicated metrics and multiple metrics at the same time

- better classification than median -> clustering with k-means?

- non rectangular windows? do end effects matter? not with simple metrics?

= References

#bibliography("Thesis.bib", title: none)