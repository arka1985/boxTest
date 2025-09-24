# boxTest

<!-- badges: start -->

<!-- badges: end -->

The **boxTest** package provides a simple way to compare two groups using boxplots and statistical tests.
It automatically checks normality (via Shapiro–Wilk test) and then applies the appropriate test:

* Independent 2-sample *t*-test (if both groups are normally distributed)
* Mann–Whitney U test (if at least one group is non-normal)

It also generates a **publication-ready boxplot** with jittered points.

---

## Installation

### From GitHub (development version)

```r
# install.packages("remotes")  # if not already installed
remotes::install_github("arka1985/boxTest")
```

### From CRAN (once accepted)

```r
install.packages("boxTest")
```

### From tar.gz release

Download the `.tar.gz` file from [Releases](https://github.com/arka1985/boxTest/releases) and install locally:

```r
install.packages("path/to/boxTest_0.1.0.tar.gz", repos = NULL, type = "source")
```

---

## Example

```r
library(boxTest)

# Create a sample dataset: Male and Female BMI
df <- data.frame(
  gender = rep(c("Male", "Female"), each = 10),
  BMI = c(22, 24, 25, 23, 26, 28, 24, 23, 27, 25,
          21, 22, 23, 20, 24, 22, 21, 23, 22, 21)
)

# Compare BMI between Male and Female
res <- compare_two_groups(df, "BMI", "gender")

# Show the boxplot
print(res$plot)

# Normality test results
print(res$normality)

# Test summary (t-test or Mann–Whitney U)
print(res$test_summary)
```

---

## Output

* **`res$plot`** → A ggplot object showing the boxplot with jittered points
* **`res$normality`** → Shapiro–Wilk test results for each group
* **`res$test_summary`** → Test used, statistic, df (if applicable), and p-value

---

## Authors

* Arkaprabha Sau (Author & Maintainer)
* Santanu Phadikar (Author)
* Ishita Bhakta (Author)
