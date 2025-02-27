test_that("bundling + unbundling parsnip model_fits (xgboost)", {
  skip_if_not_installed("parsnip")
  skip_if_not_installed("xgboost")

  library(parsnip)
  library(xgboost)

  set.seed(1)

  mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost") %>%
    fit(mpg ~ ., data = mtcars)

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_model_fit")
  expect_s3_class(mod_unbundled, "_xgb.Booster")
  expect_s3_class(mod_unbundled, "model_fit")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod$situate)))

  mod_preds <- predict(mod, mtcars)
  mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars)

  expect_equal(mod_preds, mod_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  mod_unbundled_preds_new <- callr::r(
    function(mod_bundle_) {
      library(bundle)
      library(parsnip)
      library(xgboost)

      mod_unbundled_ <- unbundle(mod_bundle_)
      predict(mod_unbundled_, mtcars)
    },
    args = list(
      mod_bundle_ = mod_bundle
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})

test_that("bundling + unbundling parsnip model_fits (lightgbm)", {
  skip_if_not_installed("parsnip")
  skip_if_not_installed("bonsai")
  skip_if_not_installed("lightgbm")

  library(parsnip)
  library(bonsai)
  library(lightgbm)

  set.seed(1)

  mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("lightgbm") %>%
    fit(mpg ~ ., data = mtcars)

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_model_fit")
  expect_s3_class(mod_unbundled, "_lgb.Booster")
  expect_s3_class(mod_unbundled, "model_fit")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod$situate)))

  mod_preds <- predict(mod, mtcars)
  mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars)

  expect_equal(mod_preds, mod_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  mod_unbundled_preds_new <- callr::r(
    function(mod_bundle_) {
      library(bundle)
      library(parsnip)
      library(lightgbm)

      mod_unbundled_ <- unbundle(mod_bundle_)
      predict(mod_unbundled_, mtcars)
    },
    args = list(
      mod_bundle_ = mod_bundle
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})
