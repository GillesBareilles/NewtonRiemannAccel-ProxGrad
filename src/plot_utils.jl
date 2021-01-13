#
## Helper functions.
#
function get_iteratesplot_params(optimizer, COLORS, algoid)
    return Dict{Any,Any}(
        "mark" => MARKERS[mod(algoid, 7) + 1],
        "color" => COLORS[algoid],
        "smooth" => nothing
        # "mark phase" => 7,
        # "mark options" => "draw=black",
    )
end


function add_contour!(plotdata, pb, xmin, xmax, ymin, ymax)
    x = xmin:((xmax - xmin) / 100):xmax
    y = ymin:((ymax - ymin) / 100):ymax
    F = (x, y) -> f(pb, [x, y])

    @assert problem_dimension(pb) == 2 "Problem should be two dimensional."

    # push!(
    #     plotdata,
    #     PlotInc(
    #         PGFPlotsX.Options(
    #             "forget plot" => nothing,
    #             "no marks" => nothing,
    #             "ultra thin" => nothing,
    #         ),
    #         Table(contours(x, y, F.(x, y'), 10)),
    #     ),
    # )

    push!(plotdata, @pgf Plot({
            contour_prepared = {
                labels = false,
            },
            point_meta = z,
        },
        Table(contours(x, y, F.(x, y'))),
        )
    )
    return

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
