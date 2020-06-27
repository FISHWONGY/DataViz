```{r}
library(rword2vec)
library(readr)
library(scales)
library(tidyverse)
library(quanteda.dictionaries)
library(quanteda)
```

```{r}
ff_tw <- suppressWarnings(read_csv("final_fan.csv", na = "NULL"))
```

```{r}
lang <- ff_tw %>% 
               group_by(lang) %>% 
               count(lang) %>%
               ungroup() %>%
               arrange(-n) 

lang
```

```{r}
ht <- str_extract_all(ff_tw$text, "#[A-Za-z0-9_]+")
ht <- unlist(ht)
head(sort(table(ht), decreasing = TRUE))
ht <- as.data.frame(sort(table(ht), decreasing = FALSE))
ht <- ht %>% filter(Freq > 100)
```

#Extract FF tweets
```{r}
ff <- ff_tw[grep("final fantasy?", ff_tw$text, ignore.case = T), ]
```

```{r}
ff_corpus <- corpus(ff, text_field = "text")
```

```{r, fig.height=5}
corpus_subset(ff_corpus, 
              lang %in% c("en", "ja", "es")) %>%
    dfm(groups = "lang", remove = c(stopwords("english"), "hongkong", "hong", "kong", "protests", "weeks", "mr", "ms", "yesterday", "said", "also", "and", "32", "can", "set", "two", "since", "took", "well"), remove_punct = TRUE, remove_numbers = TRUE, remove_separators = FALSE) %>%
    dfm_trim(min_termfreq = 160, verbose = FALSE) %>%
    textplot_wordcloud(comparison = TRUE, color = c("royalblue4", "#83B692", "red3"), rotation = 0)
```



```{r}
ff_en <- ff_tw %>%
  filter(lang == "en") %>%
  select("text")
```

```{r}
ff_corpus <- corpus(ff_en)
```

Now we're ready to run the sentiment analysis! First we will construct a dictionary object.

```{r}
#Create a dictionary
data(data_dictionary_geninqposneg)

#[[]] = pulling out specific word
pos.words <- data_dictionary_geninqposneg[['positive']]
neg.words <- data_dictionary_geninqposneg[['negative']]
mydict <- dictionary(list(positive = pos.words,
                          negative = neg.words))
```

```{r}
#Instead of using everyword from corpus, we can use the words from the dictinary
sent <- dfm(ff_corpus, dictionary = mydict)
```

```{r}
#We can take the countof each of these dict keys
#Give a new column call: score
ff_en$score <- as.numeric(sent[,1]) - as.numeric(sent[,2])
```

```{r}
ff_en <- ff_en %>%
          mutate(sentiment = case_when(score < 0 ~ "Negative",
                                       score == 0 ~ "Neutral",
                                       score > 0 ~ "Positive"))
```


```{r}
en_corpus <- corpus(ff_en, text_field = "text")
```

POS = music, character, story
neg = hard, difficult, gloomy, easy
```{r, fig.height=5}
corpus_subset(en_corpus, 
              sentiment %in% c("Negative", "Neutral", "Positive")) %>%
    dfm(groups = "sentiment", remove = c(stopwords("english"), "hongkong", "hong", "kong", "protests", "weeks", "mr", "ms", "yesterday", "said", "also", "and", "32", "can", "set", "two", "since", "took", "well"), remove_punct = TRUE, remove_numbers = TRUE, remove_separators = FALSE) %>%
    dfm_trim(min_termfreq = 60, verbose = FALSE) %>%
    textplot_wordcloud(comparison = TRUE, color = c("royalblue4", "#83B692", "red3"), rotation = 0)
```

```{r, fig.height=5}
corpus_subset(en_corpus, 
              sentiment == "Positive") %>%
    dfm(remove = c(stopwords("english")), remove_punct = TRUE, remove_numbers = TRUE, remove_separators = FALSE) %>%
    dfm_trim(min_termfreq = 10, verbose = FALSE) %>%
    textplot_wordcloud(color = rev(RColorBrewer::brewer.pal(10, "RdBu")), rotation = 0)
```






```{r}
train <- gsub("[[:punct:]]", "", ff_en)
train <- tolower(train)
write(train, "text_data.txt")
```

```{r}
#Convert phrases to words
word2phrase(train_file = "text_data.txt", output_file = "vec.txt")
```

```{r}
#Input words to model
model <- word2vec(train_file = "vec.txt", output_file = "vec(w4).bin", binary = 1, window = 4, layer1_size = 200)
```

```{r}
bin_to_txt("vec(w4).bin", "modeltext.txt")
```

```{r}
data <- read_delim("/Volumes/My Passport for Mac/R/Twitter Scrapping/17 Jun 20 Final_Fantasy/modeltext.txt", 
	skip = 1, delim = " ",
	col_names = c("word", paste0("V", 1:200)))
data[1:10, 1:6]
```

```{r}
plot_words <- function(words, data){
  # empty plot
  plot(0, 0, xlim = c(-2.5, 2.5), ylim = c(-2.5,2.5), type = "n",
       xlab = "First dimension", ylab = "Second dimension")
  for (word in words){
    # extract first two dimensions
    vector <- as.numeric(unlist(data[data$word == word, 2:3]))
    # add to plot
    text(vector[1], vector[2], labels=word)
  }
}


plot_words(c("character", "characters", "music", "story", "nice", "good", "hard", "diffcult", "love", "storyline", "finalfantasy"), data)
```

```{r}
music_df <- as.data.frame(distance(file_name = "vec(w4).bin",
		search_word = "music",
		num = 500))

music_df$Ego <- "music"

cha_df <- distance(file_name = "vec(w4).bin",
		search_word = "characters",
		num = 500)
cha_df$Ego <- "characters"

story_df <- distance(file_name = "vec(w4).bin",
		search_word = "story",
		num = 500)
story_df$Ego <- "story"

hard_df <- distance(file_name = "vec(w4).bin",
		search_word = "hard",
		num = 100)
hard_df$Ego <- "hard"
```

```{r}
nw_df <- bind_rows(music_df, cha_df, story_df, hard_df)
nw_df <- nw_df[, c(3,1,2)]
colnames(nw_df)[2] <- "Alter"
nw_df$dist <- as.numeric(paste(nw_df$dist))
```

```{r}
nw_df2 <- nw_df %>% 
         filter(Alter %in% c("story", "music", "characters", "hard", "perfect", "boss", "battle", "song", "nice", "bad", "difficult", "beautiful", "lightning", "underrated", "memories", "victory", "powerful", "franchise"))
```

**Generate network**
```{r}
require("igraph") 
```

```{r}
we_net <- graph_from_data_frame(d = nw_df2, directed = T) 
#V(we_net)$ego <- nw_df$Ego
#`v`9weV(we_net)$col <- uni$Freq
E(we_net)$weight <- nw_df2$dist
```

```{r}
#l <- layout_with_fr(we_net)
l <- layout_with_kk(we_net)

# Count the number of degree for each node:
deg <- degree(we_net, mode = "all")

#V(net)$color <- colrs[V(net)$media.type]
edge.start <- ends(we_net, es = E(we_net), names = F)[, 1]
#edge.col <- V(we_net2)$color[edge.start]
```

vertex.color = V(we_net)$ego, 
```{r, fig.width=15, fig.height=15}
plot(we_net, 
     vertex.label = V(we_net)$name, vertex.label.cex = 2.5, vertex.size = rescale(deg, c(1, 10)),
     vertex.color =  "pink",
     edge.color = edge.start,
     edge.width = rescale(E(we_net)$weight*3, c(1, 15)), edge.arrow.size = 2, edge.curved = 0.3, 
     vertex.label.color = "black", layout = l)

legend("topright", legend = c("From music", "From characters", "From story", "From hard"), pch = 19, cex = 2, col = categorical_pal(4)[c(1, 2, 3,4)]) 
```

