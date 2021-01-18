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
