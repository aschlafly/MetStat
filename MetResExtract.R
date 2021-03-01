library(tidyverse)
library(pdftools)
library(jsonlite)

res_cats = 
  data.frame(res_cat = c("01","02","03","04","05","06","07"),
             category = c("Life Insurance",
                          "Annuities",
                          "Supp Conts with Life Conts",
                          "Accidental Death Bens",
                          "Disability - Active",
                          "Disability - Disabled",
                          "Miscellaneous"))
res_cats


#met = pdf_text("2019-MLIC-Annual-Statement.pdf")
met = pdf_text("2020-MLIC-Annual-Statutory-Statement.pdf")
grep(pattern = "EXHIBIT 5 - AGGREGATE", x = met)
(ex5 = str_c(met[grep("EXHIBIT 5 - AGGREGATE", met)], collapse = "\n"))
str(ex5)
str_length(ex5)
str_length(met[grep("EXHIBIT 5(?!A)", met)])
str_split(ex5, "\n")

res_lines = t(str_extract_all(string = ex5,pattern = "\\d{7}.{1,}",simplify = TRUE))
length(res_lines)

# Line 42 has an interest rate typo causes a split that should not occur for both 2019 and 2020
str_sub(res_lines[42], start = 1, end = 40)
res_lines[42] = str_replace(string = res_lines[42], 
                            pattern = "58 CSO, 3 .5", 
                            replacement = "58 CSO, 3.5")
str_sub(res_lines[42], start = 1, end = 40)

# Line 459 has a similar typo for 2020 ONLY
str_sub(res_lines[459], start = 1, end = 40)
res_lines[459] = str_replace(string = res_lines[459], 
                            pattern = "a-2012, Proj G2 .75", 
                            replacement = "a-2012, Proj G2.75")
str_sub(res_lines[459], start = 1, end = 40)

ex5_parts = str_split(string = res_lines, pattern = "(?<!,)\\s\\.", simplify = TRUE)
ex5_raw_df = as.data.frame(ex5_parts)
# If all goes well, there is no column V7.
#ex5_raw_df$V7[ex5_raw_df$V7 != ""]

names(ex5_raw_df) 
ex = "(\\s|,|\\.)"

ex5_re_df = ex5_raw_df %>%
  filter(str_detect(string = V1, pattern = "Reinsurance ceded")) %>%
  mutate(total = -as.numeric(str_replace_all(string = V2, pattern = ex, replacement = "")),
         industrial = -as.numeric(str_replace_all(string = V3, pattern = ex, replacement = "")),
         ordinary = -as.numeric(str_replace_all(string = V4, pattern = ex, replacement = "")),
         credit = -as.numeric(str_replace_all(string = V5, pattern = ex, replacement = "")),
         group = -as.numeric(str_replace_all(string = V6, pattern = ex, replacement = "")),
         gross_ceded = "ceded"
  )

ex5_gross_df = ex5_raw_df %>%
  filter(str_detect(string = V1, pattern = "[09]\\d9999[789]\\.", negate = TRUE)) %>%
  mutate(total = as.numeric(str_replace_all(string = V2, pattern = ex, replacement = "")),
         industrial = as.numeric(str_replace_all(string = V3, pattern = ex, replacement = "")),
         ordinary = as.numeric(str_replace_all(string = V4, pattern = ex, replacement = "")),
         credit = as.numeric(str_replace_all(string = V5, pattern = ex, replacement = "")),
         group = as.numeric(str_replace_all(string = V6, pattern = ex, replacement = "")),
         gross_ceded = "gross"
  )


ex5_df = ex5_gross_df %>% 
  bind_rows(ex5_re_df) %>% 
  select(V1, total:gross_ceded) %>%
  mutate(res_cat = str_sub(V1, start = 1, end = 2),
         entry_no = str_sub(V1, start = 1, end = 7),
         val_standard = str_remove_all(V1,"\\d{7}\\.\\s|\\.{2,}"),
         val_rate = str_extract(val_standard,"(\\d|\\.)*%")) %>%
  left_join(res_cats, by = "res_cat") %>%
  select(-V1) %>%
  relocate(gross_ceded:category, .before = total)
names(ex5_df)
head(ex5_df)

ex5_df %>% group_by(res_cat, gross_ceded) %>% summarize(across(total:group,sum, na.rm = TRUE))

write_csv(x = ex5_df, file = "MLIC_Exhibit5_2020.csv")
write_json(x = ex5_df, path = "MLIC_Exhibit5_2020.json")
