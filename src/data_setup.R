pacman::p_load(tidyverse)

rpf <- read_csv('~/Documents/misc_data/RPF_Peixian/AO3_Celebrities & Real People.csv')
all_snippets_meta <- read_csv("~/Documents/misc_data/data/all_snippets_meta(1).csv")


cats_count <- rpf %>% 
  count(subcategories) %>% 
  arrange(desc(n)) 

quantile(cats_count$n, probs = c(0.01, 0.05, 0.10, 0.269,0.50, 0.90, 0.95, 0.975, 0.99))


small_cats <- cats_count %>% 
  filter(n<=5)

medium_cats <- cats_count %>% 
  filter(n > 199, n < 349)


dream <- rpf %>% 
  filter(subcategories == "Dream SMP") %>%
  distinct(work_id, .keep_all = T) %>% 
  mutate(label = "Dream SMP")

xfiles <- rpf %>% 
  filter(subcategories == "The X-Files RPF") %>% 
  distinct(work_id, .keep_all = T) %>% 
  mutate(label = "The X-Files RPF")

small <- rpf %>% 
  filter(subcategories %in% small_cats$subcategories) %>% 
  distinct(work_id, .keep_all = T) %>% 
  mutate(label = "Small Fandoms")

medium <- rpf %>% 
  filter(subcategories %in% medium_cats$subcategories) %>% 
  distinct(work_id, .keep_all = T) %>% 
  mutate(label = "Medium Fandoms")


raw_df <- rbind(dream, xfiles, small, medium) 

clean_df <- raw_df %>% 
  mutate(date = as.Date(date, format = "%d %b %Y")) %>% 
  select(work_id, work_author, work_title, date, fandoms, tags, Relationships, language, Words, `Chapters:`, `Comments:`, `Kudos:`, `Bookmarks:`, `Hits:`, `Content rating`, label) %>% 
  rename(author = work_author,
         title = work_title,
         fandom = fandoms, 
         published = date, 
         category = Relationships,
         chapters = `Chapters:`,
         comments = `Comments:`,
         kudos = `Kudos:`,
         hits = `Hits:`, 
         bookmarks = `Bookmarks:`,
         rating = `Content rating`,
         word_count = Words) %>% 
  replace(is.na(.), 0)

hp <- all_snippets_meta %>% 
  filter(fandom_label =="HP") %>% 
  mutate(relationship = str_sub(relationship, 1, -2),
         character = str_sub(character, 2, -2),
         freeform = str_sub(freeform, 2, -1),
         tags = paste(relationship, character, freeform, sep = " "),
         language = "English",
         category = "",
         rating = str_sub(rating, 3, -3),
         label = "Harry Potter") %>%
  select(work_id, author, title, published, fandom, tags, category, language, word_count, chapters, comments, kudos, bookmarks, hits, rating, label) %>% 
  replace(is.na(.), "NA") %>% 
  filter(rating %in% c("Explicit", "Mature", "Teen And Up Audiences", "General Audiences", "Not Rated"))


combined <- rbind(clean_df, hp) 

dups <- combined %>% 
  count(work_id) %>% 
  filter(n>1)

df <- combined %>% 
  filter(kudos <= hits,
         hits >0,
         kudos >0,
         !work_id %in% dups$work_id) %>% 
  mutate(khr = ((kudos )/ (hits))*100,
         ckr = ((comments) / (kudos))*100) 

df %>% 
  count(label)

df_anon <- df %>% 
  mutate(anon_work_id = as.numeric(as.factor(work_id)),
         anon_author = as.numeric(as.factor(author))) %>% 
  relocate(anon_work_id, anon_author) %>% 
  select(!c(work_id, author))

tags_df <- df_anon %>% 
  select(anon_work_id, anon_author, label, tags)

df_anon <- df_anon %>% 
  select(!c(tags))

write_csv(df, "dat/peripheries_data.csv")
write_csv(df_anon, "dat/peripheries_data_anon.csv")
write_csv(tags_df, "dat/tags_data_anon.csv")


######## because tags_df is too big for git, we will make a sample to upload ########
sample_ids <- sample(tags_df$anon_work_id, 34486) # 10% of the data

sample_tags_df <- tags_df %>% 
  filter(anon_work_id %in% sample_ids)
write_csv(sample_tags_df, "dat/sample_tags_data_anon.csv")
