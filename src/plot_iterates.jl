COLORS_7 = [
    Colors.RGB(68/255, 119/255, 170/255),
    Colors.RGB(102/255, 204/255, 238/255),
    Colors.RGB(34/255, 136/255, 51/255),
    Colors.RGB(204/255, 187/255, 68/255),
    Colors.RGB(238/255, 102/255, 119/255),
    Colors.RGB(170/255, 51/255, 119/255),
    Colors.RGB(187/255, 187/255, 187/255),
]

MARKERS = [
    "x",
    "+",
    "star",
    "oplus",
    "triangle",
    "diamond",
    "pentagon",
]

function get_iteratesplot_params(optimizer, COLORS, algoid)
    return Dict{Any,Any}(
        "mark" => MARKERS[mod(algoid, 7) + 1],
        "color" => COLORS[algoid],
        "line width" => "1pt",
        "mark size" => "3pt",
        # "smooth" => nothing
        # "mark phase" => 7,
        # "mark options" => "draw=black",
    )
end

function add_point!(plotdata, xopt)
    coords = [(xopt[1], xopt[2])]

    push!(
        plotdata,
        PlotInc(
            PGFPlotsX.Options(
                "forget plot" => nothing,
                "only marks" => nothing,
                "mark" => "star",
                "thick" => nothing,
                "color" => "black",
            ),
            Coordinates(coords),
        ),
    )

    return
end

function add_manifold!(ps, coords)
    push!(
        ps,
        PlotInc(
            PGFPlotsX.Options(
                "forget plot" => nothing,
                "no marks" => nothing,
                "smooth" => nothing,
                "thick" => nothing,
                "solid" => nothing,
                "black!50!white" => nothing,
                # "mark size" => "1pt"
            ),
            Coordinates(coords),
        ),
    )
    return
end




"""
    plot_iterates(pb, optimizer_to_trace)

Plot iterates for 2d problems.
"""
function plot_iterates(pb, optimizer_to_trace::AbstractDict{Optimizer,Any})

    ## TODOs: - automatic / paramters for xmin, xmax, ymin, ymax.
    ## TODOs: - Set colors as in AI paper
    ntraces = length(optimizer_to_trace)
    COLORS = (ntraces <= 7 ? COLORS_7 : COLORS_10)

    xmin, xmax = -0.2, 0.5
    ymin, ymax = -0.2, 0.5

    axis = @pgf Axis({
            # contour_prepared,
            # view = "{0}{90}",
            # height = "12cm",
            # width = "12cm",
            xmin = xmin,
            xmax = xmax,
            ymin = ymin,
            ymax = ymax,
            legend_pos = "outer north east",
            legend_cell_align = "left",
            legend_style = "font=\\footnotesize",
            # title = "Problem $(pb.name) -- Iterates postion",
    })

    ## Plot contour
    # add_contour!(plotdata, pb, xmin, xmax, ymin, ymax)
    x = xmin:((xmax - xmin) / 100):xmax
    y = ymin:((ymax - ymin) / 100):ymax
    φ(x, y) = F(pb, [x, y])
    push!(axis, @pgf Plot(
        {
            forget_plot,
            contour_prepared,
            no_marks,
            ultra_thin,
        },
        Table({"col sep"="space"}, contours(x, y, φ.(x, y'))))
    )

    ## Plot algorithms iterates
    algoid = 1
    for (optimizer, trace) in optimizer_to_trace
        coords = [(state.additionalinfo.x[1], state.additionalinfo.x[2]) for state in trace]

        push!(axis, PlotInc(
                PGFPlotsX.Options(get_iteratesplot_params(optimizer, COLORS, algoid)...),
                Coordinates(coords),
        ))
        push!(axis, LegendEntry(get_legendname(optimizer)))

        algoid += 1
    end

    ## Plot optimal point
    add_point!(axis, [0.0, 0.0])

    ## Plot manifolds
    xs = collect(xmin:(xmax-xmin)/100:xmax)
    coords = [(x, x^2) for x in xs]
    add_manifold!(axis, coords)

    return TikzDocument(TikzPicture(axis))
end
