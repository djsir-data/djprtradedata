test_that("read_supp() produce expected output", {
  all_fy <- read_supp()

  expect_type(all_fy, "list")
  lapply(all_fy, expect_s3_class, class = "tbl_df")
})