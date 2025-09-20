library(testthat)
library(boxTest)

test_that("compare_two_groups works with mtcars", {
  res <- compare_two_groups(mtcars, "mpg", "am")

  # ---- Check plot object ----
  expect_s3_class(res$plot, "ggplot")

  # ---- Check normality dataframe ----
  expect_true(all(c("group", "shapiro_W", "p_value", "normal") %in% names(res$normality)))

  # ---- Check test summary dataframe ----
  expect_true(all(c("method", "statistic", "df", "p_value") %in% names(res$test_summary)))

  # ---- Optional: Check that method is t-test or Wilcoxon ----
  expect_true(res$test_summary$method %in% c("Independent 2-sample t-test", "Wilcoxon rank-sum test"))
})
