pacman::p_load(tidyverse)

df <- read_csv("dat/peripheries_data_anon.csv")

############# let's do it ###############

stats <- df %>% 
  group_by(label) %>% 
  summarise(mean_hits = mean(hits), 
            median_hits = median(hits),
            mean_kudos = mean(kudos),
            median_kudos = median(kudos),
            mean_comments = mean(comments),
            median_comments = median(comments),
            mean_khr = mean(khr),
            max_khr = max(khr),
            median_khr = median(khr),
            mean_ckr = mean(ckr),
            max_ckr = max(ckr),
            median_ckr = median(ckr)) %>% 
  mutate(label = factor(label, levels = c("Harry Potter", "Dream SMP", "The X-Files RPF", "Medium Fandoms", "Small Fandoms")))


stats_long <- stats %>% 
  pivot_longer(cols = c(starts_with('median'), starts_with('mean'), starts_with("max")), names_to = "stat") %>% 
  mutate(stat = factor(stat, levels = c("max_khr","max_ckr", "mean_ckr","median_ckr", "mean_khr", "median_khr",
                                        "mean_kudos", "median_kudos","mean_comments",  "median_comments",
                                        "mean_hits", "median_hits")))

stats_long %>% 
  ggplot(aes(label, value, fill = label), )+
  geom_bar(stat = "identity")+
  geom_text(aes(label = round(value, 1), vjust= .5, size = 2))+
  facet_wrap(~stat, ncol = 2, scales = "free")+
  theme_bw()+
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())

ggsave("figures/stats.png", width = 7, height = 8)


ratings_stats <- df %>% 
  group_by(label, rating) %>% 
  summarise(n = n(), 
            mean_hits = mean(hits),
            mean_kudos = mean(kudos),
            mean_khr = mean(khr),
            mean_ckr = mean(ckr)) %>% 
  mutate(pct = n/sum(n)*100,
         rating = factor(rating, levels = c("General Audiences", "Teen And Up Audiences", 
                         "Mature", "Explicit", "Not Rated"))) %>% 
  arrange(rating)

ggplot(ratings_stats, aes(label, pct, fill = label))+
  geom_bar(stat = "identity")+
  geom_text(aes(label = round(pct, 1)), vjust = 1)+
  facet_wrap(~rating, ncol = 2)+
  theme_bw()+
  theme(axis.ticks.x = element_blank(),axis.text.x = element_blank())

ggsave("figures/ratings.png", width = 6, height = 6)


gender_cats <- df %>% 
  filter(label != "Harry Potter") %>% 
  count(label, category)

gender_cats %>% 
  filter(label == "The X-Files RPF") %>% 
  arrange(desc(n))
gender_cats %>% 
  filter(label == "Dream SMP")%>% 
  arrange(desc(n))
gender_cats %>% 
  filter(label == "Small Fandoms")%>% 
  arrange(desc(n))
gender_cats %>% 
  filter(label == "Medium Fandoms")%>% 
  arrange(desc(n))

cats <- c("M/M", "F/M", "F/F", "No Category", "Gen", "Multi", "Other")

gender_stats <- df %>% 
  filter(category %in% cats) %>% 
  group_by(label, category) %>% 
  summarise(n = n(),
            mean_hits = mean(hits),
            mean_kudos = mean(kudos),
            mean_khr = mean(khr),
            mean_ckr = mean(ckr)) %>% 
  mutate(pct = (n/sum(n))*100)


gender_rating <- df %>% 
  filter(category %in% cats) %>% 
  count(label, category, rating) 

