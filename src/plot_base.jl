COLORS_7 = [
    Colors.RGB(68 / 255, 119 / 255, 170 / 255),
    Colors.RGB(102 / 255, 204 / 255, 238 / 255),
    Colors.RGB(34 / 255, 136 / 255, 51 / 255),
    Colors.RGB(204 / 255, 187 / 255, 68 / 255),
    Colors.RGB(238 / 255, 102 / 255, 119 / 255),
    Colors.RGB(170 / 255, 51 / 255, 119 / 255),
    Colors.RGB(187 / 255, 187 / 255, 187 / 255),
]

COLORS_10 = [
    colorant"#332288",
    colorant"#88CCEE",
    colorant"#44AA99",
    colorant"#117733",
    colorant"#999933",
    colorant"#DDCC77",
    colorant"#CC6677",
    colorant"#882255",
    colorant"#AA4499",
    colorant"#DDDDDD",
]

MARKERS = ["x", "+", "star", "oplus", "triangle", "diamond", "pentagon"]


get_legendname(optimizer) = dispname(optimizer)

function get_curve_params(optimizer, COLORS, algoid, markrepeat)
    return Dict{Any,Any}(
        "mark" => MARKERS[mod(algoid, 7) + 1],
        "color" => COLORS[algoid],
        "mark repeat" => markrepeat,
        # "mark phase" => 7,
        # "mark options" => "draw=black",
    )
end

function plot_curves(
    optimizer_to_trace::AbstractDict{Optimizer,Any},
    get_abscisses,
    get_ordinates;
    xlabel = "time (s)",
    ylabel = "",
    xmode = "normal",
    ymode = "log",
    nmarks = 15,
    includelegend = true,
    horizontallines = []
)
    plotdata = []
    ntraces = length(optimizer_to_trace)
    COLORS = (ntraces <= 7 ? COLORS_7 : COLORS_10)

    maxloggedvalues = maximum(length(trace) for trace in values(optimizer_to_trace))
    markrepeat = floor(maxloggedvalues / nmarks)

    algoid = 1
    for (optimizer, trace) in optimizer_to_trace
        eachnthpoint = max(1, Int64(floor(length(trace) / 3e2)))
        # tracelight = [ elt for (i, elt) in enumerate(trace) if mod(i-1, eachnthpoint) == 0]
        tracelight = trace

        push!(
            plotdata,
            PlotInc(
                PGFPlotsX.Options(
                    # "each_nth_point" => eachnthpoint,
                    # "filter_discard_warning" => false,
                    # "unbounded_coords" => "discard",
                    get_curve_params(optimizer, COLORS, algoid, 10)...,
                ),
                Coordinates(get_abscisses(tracelight), get_ordinates(optimizer, tracelight)),
            ),
        )
        includelegend && push!(plotdata, LegendEntry(get_legendname(optimizer)))
        algoid += 1
    end

    for hlevel in horizontallines
        push!(plotdata, @pgf HLine({ dashed, black }, hlevel))
    end

    return @pgf Axis(
        {
            xmode = xmode,
            ymode = ymode,
            # height = "10cm",
            # width = "10cm",
            xlabel = xlabel,
            ylabel = ylabel,
            legend_pos = "outer north east",
            legend_style = "font=\\footnotesize",
            legend_cell_align = "left",
            unbounded_coords = "jump",
            xmin = 0,
        },
        plotdata...,
    )
end
