#' Compare Two Groups with Boxplot and Significance Test
#'
#' Generates side-by-side boxplots and runs Shapiro-Wilk by group,
#' then t-test (if both normal) or Wilcoxon rank-sum test.
#' Returns a structured list with plots and a clear test summary.
#'
#' @param data A data.frame
#' @param continuous Name of continuous variable (string)
#' @param group Name of categorical variable with exactly 2 levels (string)
#' @return A list containing:
#'   \describe{
#'     \item{plot}{A ggplot object of the boxplot.}
#'     \item{normality}{A data.frame showing Shapiro-Wilk p-values for each group.}
#'     \item{test_summary}{A data.frame summarizing the statistical test used, statistic, df, and p-value.}
#'   }
#' @examples
#' res <- compare_two_groups(mtcars, "mpg", "am")
#' res$plot
#' res$normality
#' res$test_summary
#' @export
compare_two_groups <- function(data, continuous, group) {
  # ---- Input validation ----
  if (!(continuous %in% names(data)) || !(group %in% names(data))) {
    stop("Error: Variables not found in dataframe.")
  }

  df <- data |>
    dplyr::select(dplyr::all_of(c(continuous, group))) |>
    stats::na.omit()

  df[[group]] <- as.factor(df[[group]])
  if (length(unique(df[[group]])) != 2) {
    stop("Error: Grouping variable must have exactly 2 categories.")
  }

  # ---- Tidy evaluation for ggplot ----
  continuous_sym <- rlang::sym(continuous)
  group_sym <- rlang::sym(group)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = !!group_sym, y = !!continuous_sym, fill = !!group_sym)) +
    ggplot2::geom_boxplot(alpha = 0.6, width = 0.6, outlier.color = "red") +
    ggplot2::geom_jitter(width = 0.15, alpha = 0.5, color = "black") +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::labs(
      x = group,
      y = continuous,
      title = paste("Boxplot of", continuous, "by", group),
      subtitle = "Red dots indicate outliers"
    ) +
    ggplot2::theme(legend.position = "none")

  # ---- Normality check ----
  glevels <- levels(df[[group]])
  sw_results <- lapply(glevels, function(g) {
    stats::shapiro.test(df[df[[group]] == g, continuous])
  })
  names(sw_results) <- glevels

  normality_df <- data.frame(
    group = glevels,
    shapiro_W = sapply(sw_results, function(x) x$statistic),
    p_value = sapply(sw_results, function(x) x$p.value)
  )
  normality_df$normal <- normality_df$p_value > 0.05

  normal <- all(normality_df$normal)

  # ---- Choose appropriate test ----
  if (normal) {
    test_result <- stats::t.test(df[[continuous]] ~ df[[group]], var.equal = TRUE)
    method <- "Independent 2-sample t-test"
    dfree <- unname(test_result$parameter)
  } else {
    test_result <- stats::wilcox.test(df[[continuous]] ~ df[[group]])
    method <- "Wilcoxon rank-sum test"
    dfree <- NA
  }

  test_summary <- data.frame(
    method = method,
    statistic = unname(test_result$statistic),
    df = dfree,
    p_value = test_result$p.value
  )

  # ---- Return structured output ----
  list(
    plot = p,
    normality = normality_df,
    test_summary = test_summary
  )
}

