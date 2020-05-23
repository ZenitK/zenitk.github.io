---
layout: post
title: 'Import from CSV to Elasticsearch using Logstash'
tags: [Logstash, Elasticsearch, CSV]
featured_image_thumbnail: assets/images/posts/2018/4_thumbnail.jpg
featured_image: assets/images/posts/2018/4.jpg
---

Very often when we want to test out a new feature in Elasticsearch we need some data to play with.
Unfortunately, Kibana and Elasticsearch don't provide an easy, out-of-the-box way to simply import a CSV. Here, I'll guide you step by step so that you can easily adapt it to your example.

For this blog, I've imported the usual [Hackernews stories](https://news.ycombinator.com/) from [BigQuery Public Data Sets](https://cloud.google.com/bigquery/public-data).

The schema looks like this:


| Field name  | Type      | Description                                              |
|-------------|-----------|----------------------------------------------------------|
| id          | INTEGER   | Unique story ID                                          |
| by          | STRING    | Username of submitter                                    |
| score       | INTEGER   | Story score                                              |
| time        | INTEGER   | Unix time                                                |
| time_ts     | TIMESTAMP | Human readable time in UTC (format: YYYY-MM-DD hh:mm:ss) |
| title       | STRING    | Story title                                              |
| url         | STRING    | Story url                                                |
| text        | STRING    | Story text                                               |
| deleted     | BOOLEAN   | Is deleted?                                              |
| dead        | BOOLEAN   | Is dead?                                                 |
| descendants | INTEGER   | Number of story descendants                              |
| author      | STRING    | Username of author                                       |

```
document_id,search_term,portal_id,language_tag,external_user_key,last_search_timestamp_utc,search_count
lOylspOXRKCnh2oZzIkSVw==,iphone,22,de-CH,86d40d8d-b112-4400-bf6d-c913c66dd8be,2020-04-15 09:51:08,198
20NHc7XuaAZ34qG6O1v28g==,iphone 11,22,de-CH,86d40d8d-b112-4400-bf6d-c913c66dd8be,2020-04-06 14:19:54,48
IRTE4uekJPiKOMIeVh26nQ==,kletterhose herren xl,22,de-CH,86d40d8d-b112-4400-bf6d-c913c66dd8be,2020-02-13 09:42:13,20
QhXVWnU7hHC4DZnofnHCUw==,raspberry,22,de-CH,86d40d8d-b112-4400-bf6d-c913c66dd8be,2020-01-30 12:27:01,16
```

Other sources:
