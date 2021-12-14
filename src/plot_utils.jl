 # #
# ## Helper functions.
# #
# function add_contour!(plotdata, pb, xmin, xmax, ymin, ymax)
#     x = xmin:((xmax - xmin) / 100):xmax
#     y = ymin:((ymax - ymin) / 100):ymax
#     F = (x, y) -> f(pb, [x, y])

#     @assert problem_dimension(pb) == 2 "Problem should be two dimensional."

#     # push!(
#     #     plotdata,
#     #     PlotInc(
#     #         PGFPlotsX.Options(
#     #             "forget plot" => nothing,
#     #             "no marks" => nothing,
#     #             "ultra thin" => nothing,
#     #         ),
#     #         Table(contours(x, y, F.(x, y'), 10)),
#     #     ),
#     # )

#     push!(plotdata, @pgf Plot({
#             contour_prepared = {
#                 labels = false,
#             },
#             point_meta = z,
#         },
#         Table(contours(x, y, F.(x, y'))),
#         )
#     )
#     return

# end
