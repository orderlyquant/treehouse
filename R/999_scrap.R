## rvesting treehouse brews for sale

library(tidyverse)
library(rvest)

treehouse_url <- "https://treehousebrew.com/shop"

treehouse_html <- read_html(treehouse_url)


# initial tibble setup
for_sale_items <- tibble(
  item = treehouse_html %>%
    html_elements(".grid-item-link") %>% html_attr("aria-label"),
  item_link = treehouse_html %>%
    html_elements(".grid-item-link") %>% html_attr("href") %>%
    str_replace("^/shop", treehouse_url)
)

# pull all item details
for_sale_items <- for_sale_items %>%
  rowwise() %>%
  mutate(
    html = map(item_link, read_html),
    desc = paste(
      html %>% html_element(".ProductItem-details-title") %>%
        html_text2(),
      html %>% html_element(".sqs-money-native") %>%
        html_text2(),
      html %>% html_element(".ProductItem-details-excerpt") %>%
        html_text2(),
      sep = "\n"
    )
  )

# build a multipurpose function to extract:

# 1. whether item `is_beer`
#       then
# if (is_beer) - `contents` is a table of the beer, included columns:[n, item]
#
# if !(is_beer) - `contents` is a 1-row table, included columns: [n, item]
#
get_item_contents <- function(desc) {
  
  # initialized return variable
  contents <- list(
    is_beer = FALSE,
    contents = tibble(n = integer(), item = character(), price = numeric())
  )
  
  
  #### NON BEER
  
  # non-beer terms, used to prevent false positives
  non_beer_terms <- c("chemex", "opener", "sinus", "cold brew")
  
  if (
    str_detect(
      desc,
      regex(paste(non_beer_terms, collapse = "|"), ignore_case = TRUE)
    )
  ) {
    return(contents)
  }
  
  
  
  #### MIX PACKS
  
  # Now, with items that should be, beer, deal first with mix packs
  
  desc_text <- desc %>% str_split("\n") %>% unlist()
  
  ## Handle mixed cases of beer - return `contents` if processed
  contain_position <- which(desc_text %>% str_detect("^Contain"))
  
  
  # is a mix
  if (length(contain_position) == 1) {
    
    contents$is_beer <- TRUE
    mix_contents <- desc_text[(contain_position+1):length(desc_text)] %>%
      str_subset("^[1-9]") %>%
      tibble() %>%
      set_names("x") %>%
      transmute(
        n = str_extract(x, "^[0-9]+") %>% as.integer(),
        beer = str_replace(x, "^[0-9]+ ", "")
      ) %>%
      mutate(
        price = str_split(desc, "\n") %>% unlist() %>% `[[`(2) %>% as.numeric()
      )
    
    contents$contents <- mix_contents
    
    return(contents)
    
  }
  
  #### SINGLE BEER ITEMS
  single_beer_terms <- c(
    "beer", 
    "pack", "-pack", "case", "[0-9] ?%",
    "bottle"
  )
  
  if (
    str_detect(
      desc,
      regex(paste(single_beer_terms, collapse = "|"), ignore_case = TRUE)
    )
  ) {
    contents$is_beer <- TRUE
    contents$contents <- tibble(
      n = 1,
      beer = str_split(desc, "\n") %>% unlist() %>% `[[`(1),
      price = str_split(desc, "\n") %>% unlist() %>% `[[`(2) %>% as.numeric
    )
    return(contents)
  }
  
  return(contents)
  
}

jj <- for_sale_items %>%
  mutate(find_beers = map(desc, get_item_contents)) %>%
  unnest_wider(find_beers)

jj %>% filter(is_beer) %>% select(item)



