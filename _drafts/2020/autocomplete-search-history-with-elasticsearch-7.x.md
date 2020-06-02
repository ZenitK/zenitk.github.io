---
layout: post
title: Autocomplete search history with Elasticsearch 7.x
tags:
- SearchHistory
- Autocomplete
- Elasticsearch
featured_image_thumbnail: "/assets/posts/autocomplete-screenshot.png"
featured_image: "/assets/posts/autocomplete-screenshot-1.png"
hidden: true
featured: true
description: Ways to implement autocomplete search history in Elasticsearch, and what
  to consider for production
category: Search

---
Have you ever wondered how the Autocomplete Search History feature in Chrome works? Basically you can search your own search history, and the results are mixed with other google results. This can be particularly handy in an enterprise search environment where you have a smaller amount of users who often search the same topics.

In my case, Google displays a myriad of various result types  for the search term "garm":

1. Autocomplete search history (marked with a 🕒 symbol)
2. Autocomplete search suggestion (e.g. "garmin fenix")

In this blog, we'll strictly talk only about the autocomplete search history, but strictly speaking, the Elasticsearch implementation would be very similar for both.

We'll discuss two possible approaches on how to implement it:

1. [search-as-you-type](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/search-as-you-type.html)
2. [context suggester](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/search-suggesters.html#context-suggester)

Additionally in combination with search-as-you-type, for tweaking the relevance we'll use the **rank_feature** and **distance_feature_query**.

I assume that you as a reader have some basic familiarity with Elasticsearch, but if you haven't, don't worry, they will be explained here briefly. However, do check the linked documentation if you consider implementing this yourself.

In the end, we'll talk about the _advantages_ and _disadvantages_ of each approach
and about some important technical as well as non-technical aspects that should be taken into consideration for production.

## What are our basic requirements?

First, we want the feature to be **fast**, and then also **relevant**.

Fast because it is in a search box and the user is often directly waiting for a response.

What does **relevance** in the context of one user mean? Primarily, it should match closely what the user typed in, but also it needs to be a combination of **recency** and **quantity** how often the query was executed. F.e. something the user searched yesterday three times is more likely to be relevant for them than "samsung galaxy s7" searches from 2017 that they intensely searched frequently back then. The more "distance" there is from **now** and the time the query was last executed, the less relevant it is.

## #1 Approach with search-as-you-type

The **search-as-you-type** data type was [introduced in version 7.2](https://www.elastic.co/guide/en/elasticsearch/reference/current/release-highlights-7.2.0.html#_search_as_you_type_field_mapping_type).

It's basically a convenience data type that wraps **2-gram**, **3-gram**, and an **index_prefix** field over the **3-gram** that are created in the background to cover the autocomplete functionality. So if you're running an older version of Elasticsearch you can recreate it yourself. See the Appendix for a toy implementation.

### Document Example

This is a representation of a single document in our new index. These are all fields that we'll use to execute the query.

```javascript
{
  "search_term": "iphone",
  "last_search_timestamp_utc": "2020-04-23 09:51:08",
  "search_count": 9,
  "user_id": "C4750D9F-D6B7-44AE-A40F-72C17B327EEB"
}
```

Based on the example above we define our **index mapping**.

```javascript
PUT user_search_history
{
  "mappings": {
    "properties": {
      "user_key": {
        "type": "keyword"
      },    
      "search_term": {
        "type": "search_as_you_type"
      },
      "last_search_datetime_utc": {
        "type": "date",
        "format": "yyyy-MM-dd HH:mm:ss"
      },
      "search_count": {
        "type": "rank_feature"
      }
    }
  }
}
```

Here are a few explanations:

The **user_key** is of type **keyword**, what in Elasticsearch means **we don't want any analyzer on it** and want to use it purely for filtering.
As such it should also not influence the score of the results.

We use **search_as_you_type** as the data type.

In **last_search_datetime_utc** we defined a format, but that's just optional and was added for convenience.

We save the **last search timestamp** for several reasons:

* Scoring the results (remember, the more recent, the more relevant)
* Possible deletions of unused search terms (f.e. everything older than 2 years gets deleted daily)
* To also be able to display the last N searches of a specific user
* Out of scope for this blog, but you could also do a nice aggregation of top search terms in the last week on your web site!

The next one is **search_count**, which gets incremented every time we have a new search.

### Where's the **_id**?

That depends on your implementation it's basically up to you to decide.

Here in this example it will be generated and returned by Elasticsearch, which means we would need to persist it somewhere outside of Elasticsearch.

Alternatives are:

* You generate the ID in an external DB that you also use as your source-of-truth for the search history.
* You create a hash from the search term and user id. Something like **base64(md5(lowercase(search_term + user_id)))**. This one provides
  the flexibility so that you don't need extra storage, but it might create quite a **lot of trouble** in the future, f.e. if you need another parameter.

### Insert Test Data

This is a bulk insert for some random queries. They are all assigned to our imaginary user.

```javascript
POST user_search_history/_bulk
{ "index": {} }
{ "search_term": "bowers px7", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-02-24 09:19:17", "search_count": 27}
{ "index": {} }
{ "search_term": "hard drive usb", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2019-10-26 07:20:46", "search_count": 50}
{ "index": {} }
{ "search_term": "dahle 552", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2019-10-26 14:38:23", "search_count": 23}
{ "index": {} }
{ "search_term": "notebook power bank", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2019-07-05 12:45:11", "search_count": 56}
{ "index": {} }
{ "search_term": "usb3 250 gb drive", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2019-12-28 07:56:00", "search_count": 22}
{ "index": {} }
{ "search_term": "steelserie sensei 10", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-04-04 14:33:22", "search_count": 34}
{ "index": {} }
{ "search_term": "g skill 16", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-03-19 00:07:19", "search_count": 70}
{ "index": {} }
{ "search_term": "alr screen", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2019-12-22 12:19:11", "search_count": 3}
{ "index": {} }
{ "search_term": "samsung hmd odyssey+", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-03-26 19:15:56", "search_count": 43}
{ "index": {} }
{ "search_term": "9400f", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-03-22 10:51:07", "search_count": 14}
{ "index": {} }
{ "search_term": "macbook screen protector", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-01-08 19:08:36", "search_count": 26}
{ "index": {} }
{ "search_term": "minibar", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-05-02 17:47:59", "search_count": 41}
{ "index": {} }
{ "search_term": "sony 500", "user_key": "234jjde2aj2f3f", "last_search_datetime_utc": "2020-04-24 23:37:52", "search_count": 3}
```

### Search Query

Now we're ready for the real meat. Here's an example query:

```javascript
    GET /user_search_history/_search
    {
      "_source": [
        "search_term",
        "last_search_timestamp_utc",
        "search_count"
      ],
      "query": {
        "bool": {
          "filter": [       
            {
              "term": {
                "external_user_key": "your-guid-goes-here"
              }
            }
          ],
          "must": [
            {
              "multi_match": {
                "query": "sam",
                "type": "bool_prefix",
                "fields": [
                  "search_term",
                  "search_term._2gram",
                  "search_term._3gram"
                ]
              }
            }
          ],
          "should": [
            {
              "distance_feature": {
                "field": "last_search_timestamp_utc",
                "origin": "now",
                "pivot": "1d",
                "boost": 1.8
              }
            },
            {
              "rank_feature": {
                "field": "search_count"
              }
            }
          ]
        }
      }
    }
```

We use the bool query like in a textbook here.

We use **filter query** to limit based on the specific user and also because we **don't** want it to influence the relevance score.

Then, for the actual matching, we use the multi_match with a [**bool prefix**](https://www.elastic.co/guide/en/elasticsearch/reference/master/query-dsl-match-bool-prefix-query.html#query-dsl-match-bool-prefix-query "bool prefix"). This will have the effect that if you search for "garmin fen" that "garmin" will be treated as a [term](https://www.elastic.co/guide/en/elasticsearch/reference/master/query-dsl-term-query.html#query-dsl-term-query "term") query whereas "fen" will be in a [prefix](https://www.elastic.co/guide/en/elasticsearch/reference/master/query-dsl-prefix-query.html#query-dsl-prefix-query "prefix") query. 

If this feels like a mouthful to you - don't worry, it is. Elasticsearch itself builds upon Lucene, which in this context means the whole query that we wrote up there is just like a fancy GUI to write a [Lucene Query](http://www.lucenetutorial.com/lucene-query-syntax.html "Lucene Query"). Likewise, the Elasticsearch queries themselves are often wrappers around other, simpler queries. 

## Approach with a context suggester

* Index Mapping
* Search Query

## Pros and cons of each approach

Search as you type:

* relatively slow
* higher recall
* very customizable / tunable

## Should I implement it?

TBD:
Is it worth it? Know your domain, and know your users.
Security Aspects
Tracking
How long do you store the queries? How much can you store?
Do you need a special centralized store for it? 
UX (I know I said I won't mention it, but I have to nevertheless)

I won't get deep into the UX aspects of it or how to implement it in the front end, this I'll leave to the experts.
I'll just say that if it's combined with other results like above in the google chrome example there should be also a way for the user to distinguish between those types of results.

## Other Sources

https://www.elastic.co/videos/using-the-completion-suggester

## Appendix

### Toy re-implementation of the search-as-you-type analyzers

Here's a small basis to mess around with n-grams.

```javascript
PUT my_index
{
  "settings": {
    "analysis": {
      "filter": {
         "my_2_gram_shingle_token_filter":{
          "type": "shingle",
          "min_shingle_size": 2,
          "max_shingle_size": 2,
          "output_unigrams": false
        },
        "my_3_gram_shingle_token_filter":{
          "type": "shingle",
          "min_shingle_size": 3,
          "max_shingle_size": 3,
          "output_unigrams": false
        },
        "my_2_4_edgegrams": {
          "type": "edge_ngram",
          "min_gram": 2,
          "max_gram": 4
        }
      }, 
      "analyzer": {
        "my_2_gram": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "asciifolding",
            "my_2_gram_shingle_token_filter"
          ]
        },
        "my_3_gram": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "asciifolding",
            "my_3_gram_shingle_token_filter"
          ]
        },
        "my_index_prefix": {
           "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "asciifolding",
            "my_3_gram_shingle_token_filter",
            "my_2_4_edgegrams"
          ]
        }
      }
    }
  }
}

POST my_index/_analyze
{
  "analyzer": "my_index_prefix",
  "text": "dji mavic drone pro"
}
```