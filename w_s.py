# moved to its own script because it takes ages to run.
# this should memoise

common = partial(
    Experiment,
    c,
    metrics=[Metric.MEAN],
    classify_by=Classifier.Median,
)


for resolution in [500, 100, 10, 1]:
    ws = np.arange(1, 601, step=resolution)
    for state in State:
        fig, ax = plt.subplots()
        fig.subplots_adjust(hspace=0.05)  # adjust space between Axes

        for s in [10, 50, 100]:
            ys = [common(states=[state], w=int(w), s=s).f1_macro_average for w in ws]
            ax.plot(
                ws,
                ys,
                label=f"s = {s}",
            )

            print(f"Finished line s = {s}")
        ax.set_ylim(0.5, 0.9)
        ax.set_xlim(0, 600)
        ax.set_xlabel("w (s)")
        ax.set_ylabel("F1 Macro Average")
        ax.legend()
        ax.grid(True)
        ax.xaxis.set_major_locator(ticker.LinearLocator(11))
        ax.xaxis.set_minor_locator(ticker.AutoMinorLocator(6))
        ax.yaxis.set_minor_locator(ticker.AutoMinorLocator(5))
        plt.show()
        fig.savefig(f"assets/w_s_{state}_f{resolution}.pdf")