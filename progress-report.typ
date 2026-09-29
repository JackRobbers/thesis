#import "@preview/callisto:0.3.0"
#import "@preview/timeliney:0.4.0"
#import "eestyle2.typ": *


#let (source, display, result, output, outputs, render, Out) = callisto.config(
  nb: path("analysis.ipynb"),
)

#let render_table(label, item) = {
  // typst gives us a string starting with a #, remove that and slash it off
  eval(outputs(label, item: item).at(0).slice(1))
}


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

The main paper similar to my work @zhouCatchingHackersWatching2026, made their data publicly available @SafeNetIoTPowerIDS2026. They recorded 33 different IoT devices across 5 categories (lights, audio, cameras, tv, appliances) and under a range of scenarios both benign and hostile. So far I've only considered the idle scenario in my work to determine. Distinguishing devices may be a harder problem if the device is actively in use. Many of these devices spend the majority of the time at idle so so a solution that can identify them then is still valuable. 

There are a number of limitations with this dataset:
- The idle data for the Echo Dot 3 is truncated to 1 minute of data, hence I haven't considered it in my work.
- The nest mini3.
- Exact device models or revisions are not given. Even if the device is the same . Likely there will also be cases where manufacturing differences or differing internals are sold as the same model
- Each device was recorded for a different length of time, varying but up to a few minutes. To have a consistent dataset I've truncated the data so that each device has the same length of samples as the shortest device in the dataset. With 25 minutes of training data this leaves 12 minutes of testing.

Doesn't seem to be intended as a widely used public dataset and functioned well for their task. I will overcome some of these limitations by building my own dataset


== Method

Currently data is windowed. The size of these windows, would also determine the how quickly the profiler could respond to a newly installed device or a device that enters an abnormal state, assuming that the speed of the analysis stays negligible. 

// TODO diagram here. 

== Results



=== Effect of varying window size

#render_table("results", 0)

=== Using mean and std



== Device Profile

== Solutions

=== Future Direction / Things to try

- non rectangular windows? do end effects matter? not with simple metrics?

- better than median -> match the distribution / conformity test.

= Reflection

So far, I have not produced quality work and am unhappy with my progress. I want to finish this term so need to apply strategies to change this.

During term 1 I completed thesis A. Early in the term I was reading papers each week and familiarising myself with the field. For the report, I hadn't done enough reading, but also didn't get everything into the paper that I had investigated. I also scheduled myself to move the day after the submission. 

During term 2, I was initially working on Thesis B with a similar rate to thesis A. The goal was to both produce a dataset and a method for classifying data. I forgot to enrol in Thesis B, not noticing until week 5 when this part B progress report should have been due. I clearly was not a very engaged student. Later in the term my sleep got really bad and I was needing to take 2 naps every day. I did hardly anything from week 6-10. I sought medical attention for this and began to admit to myself that I was really struggling. I got lots of tests and discovered somewhat a cause of some issues and was able to sleep better.

So far in term 3, I've spent more time on my thesis than all of term 2.

There are factors both in and out of my control. I've had some unfortunate health issues but also have not been honest with myself about the level of commitment need to complete an honours thesis. I can only control certain things and need to learn to work with my current abilities. I view it as a vicious cycle, I don't put in the time, so lack confidence and insight in my work. I tell myself little stories and take the easy way out.

This is something I've struggled with throughout the later half of my degree but hasn't been as big of issue until a year-long project like this. I find myself to be very "momentum" based worker. Actually starting the work is often the hard part for me, once I start writing I can often concentrate for many hours. But I will procrastinate for a whole day before starting. It's self destructive. I get comfortable and coast along. I hasn't effectively used the resources at my disposal.

In the thesis meeting before this report, I came with a confusion matrix that was not working and I'd broken just before the. I was flustered and couldn't even read that graph correctly. This is obviously unacceptable and served as a wake up call. I committed to really spending the next few days doing my best work and submitting a draft of the thesis B report . Friday and Saturday were good, cleaning up the codebase and implementing the confusion matrix. Sunday I faltered, not getting any work done. On Monday, I didn't get anything done until 5pm but then had some good sessions completing the reflection and planning sections I hope through this report I've somewhat shown that I can complete this thesis. I've attempted to be genuinely introspective and honest with myself.

This thesis has taught me many things about myself and honestly is the most challenging thing I've ever done. Despite making me feel pathetic because the work is objectively not that difficult. A mental block. I'm comfortable with what I know and find it difficult to engage in short term difficulty for a result that is a long way off. But steady progress is more effective than a burst. Also the setting and time around work is so important. I find the problems overwhelming, with so many directions to go in, I get distracted tinkering around the edges, tweaking the text size on a graph when there's a glaring factual issue.

I have 7 weeks remaining in this thesis, and will take the following actions to ensure that I'm successful. Talk is cheap and I feel pathetic, lack of discipline. 7 weeks really isn't a long time. 

- Finalise results by the night before the meeting. With the morning before the meeting for reviewing results, writing up observations and. Professionalism and preparedness. Coming to the meeting unprepared is a waste of both our time. 
- Pomodoro technique / Time tracking. Apply study techniques to better use my time, getting started as early as I can in the day, and just getting something done will often give me lots of momentum. I've set myself a goal to complete on at least 20 hours of work on my thesis per week. This is averaged across days. I am also working \~10 hours a week. I will also use weekends if needed but aim to keep these free to recharge. 
- Parallel working, I reached out to and spent a few sessions working next to a friend who is also studying.  
- Therapy, I've started seeing a therapist and we are working on techniques for getting things done and sleep.

This report has many more words than thesis A.

I'd like to apologise to Hassan for, I've likely been quiet a frustrating student to deal with and thank him for his understanding. In writing this report and in particular this reflection I hope to demonstrate that I can complete this.

== Risks? 

== 

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

I aim to collect

== Method

// TODO better name?

= References

#bibliography("../Thesis.bib", title: none)