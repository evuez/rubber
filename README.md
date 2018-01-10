# Rubber [![Build Status](https://travis-ci.org/evuez/rubber.svg?branch=master)](https://travis-ci.org/evuez/rubber)

A simple Elastic client written in Elixir.

[elastix](https://github.com/werbitzky/elastix) doesn't seem to be maintained anymore so I'll try to keep this fork up-to-date.

I started off with `elastic-reloaded` for the name but then it got annoying because I wanted some consistency between the package name, the app name and the top module name so now it's `Rubber` everywhere.

## Preface

* [Official Elastic Website](https://www.elastic.co)
* [and latest docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)

This library talks to the Elastic(search) server through the HTTP/REST/JSON API. Its methods almost always return a [HTTPoison](https://github.com/edgurgel/httpoison) request object.

When needed, the payload can be provided as an Elixir Map, which is internally converted to JSON. The library does not assume anything else regarding the payload and also does not (and will never) provide a magic DSL to generate the payload. That way users can directly manipulate the API data, that is sent to the Elastic server.

## Overview

Rubber has *5 main modules* and one *utility module*, that can be used, if the call/feature you want is not implemented (yet). However – please open issues or provide pull requests so I can improve the software for everybody. The modules are:

* [Rubber.Index](lib/rubber/index.ex) corresponding to: [this official API Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices.html)
* [Rubber.Document](lib/rubber/document.ex) corresponding to: [this official API Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs.html)
* [Rubber.Search](lib/rubber/search.ex) corresponding to: [this official API Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html)
* [Rubber.Bulk](lib/rubber/bulk.ex) corresponding to: [this official API Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html)
* [Rubber.Mapping](lib/rubber/mapping.ex) corresponding to: [this official API Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html)
* and [Rubber.HTTP](lib/rubber/http.ex) – a thin [HTTPoison](https://github.com/edgurgel/httpoison) wrapper

I will try and provide documentation and examples for all of them with time, for now just consult the source code.

## Simple Example

start rubber application dependencies (or define it as an application dependency in ```mix.exs```):

```elixir
Rubber.start()

```

create the Elastic index

```elixir
Rubber.Index.create("http://127.0.0.1:9200", "sample_index_name", %{})

```

assuming you have a model ```product``` create a document, search, or delete

```elixir

# Elastic Server URL
elastic_url = "http://127.0.0.1:9200"

# Elastic Index Name
index_name = "shop_api_production"

# Elastic Document Type
doc_type = "product"

index_data = %{
  name: product.name,
  item_number: product.item_number,
  inserted_at: product.inserted_at,
  updated_at: product.updated_at
}

# Add mapping
mapping = %{
  properties: %{
    name: %{type: "text"},
    item_number: %{type: "integer"},
    inserted_at: %{type: "date"},
    updated_at: %{type: "date"}
  }
}

# add some search params according to Elastic JSON API
search_payload = %{}

# which document types should be included in the search?
search_in = [doc_type]

Rubber.Mapping.put(elastic_url, index_name, doc_type, mapping)
Rubber.Document.index(elastic_url, index_name, doc_type, product.id, index_data)
Rubber.Search.search(elastic_url, index_name, search_in, search_payload)
Rubber.Document.delete(elastic_url, index_name, doc_type, product.id)

```

### Bulk request

It is possible to execute `bulk` requests with *rubber*.

Bulk requests take as parameters the list of lines to send to *Elasticsearch*. You can also optionally give them options. Available options are:

* `index` the index of the request
* `type` the document type of the request. *(you can't specify `type` without specifying `index`)*

**Examples**

```elixir
lines = [
  %{index: %{_id: "1"}},
  %{field: "value1"},
  %{index: %{_id: "2"}},
  %{field: "value2"}
]

# Send bulk data
Rubber.Bulk.post elastic_url, lines, index: "my_index", type: "my_type"
# Send your lines by transforming them to iolist
Rubber.Bulk.post_to_iolist elastic_url, lines, index: "my_index", type: "my_type"

# Send raw data directly to the API
data = Enum.map(lines, fn line -> Poison.encode!(line) <> "\n" end)

Rubber.Bulk.post_raw elastic_url, data, index: "my_index", type: "my_type"

# Finally, you can specify the index or the type directly in you lines
lines = [
  %{index: %{_id: "1", _index: "my_index", _type: "my_type"}},
  %{field: "value1"},
  %{index: %{_id: "2", _index: "my_other_index", _type: "my_other_type"}},
  %{field: "value2"}
]

Rubber.Bulk.post elastic_url, lines
```

## Configuration

Currently we can
  * pass options to the JSON decoder used by Rubber ([poison](https://github.com/devinus/poison))
  * optionally use shield for authentication ([shield](https://www.elastic.co/products/shield))
  * optionally pass along custom headers for every request made to the elasticsearch server(s)s
  * optionally pass along options to [HTTPoison](https://github.com/edgurgel/httpoison)

by setting the respective keys in your `config/config.exs`

```elixir
config :rubber,
  poison_options: [keys: :atoms],
  shield: true,
  username: "username",
  password: "password",
  httpoison_options: [hackney: [pool: :rubber_pool]]
```

### Custom headers

To add custom headers to a request you must pass in the custom_headers option.

For example:

```elixir
config :rubber,
  custom_headers: {MyModule, :add_aws_signature, ["us-east"]}
```

This must be a `{Module, :function, [args]}` tuple. The request will be added
to the head of the args list. The args list may be empty. The request is a map
with the `method`, `headers`, `url`, and `body` keys.

The function you define should return the full set of headers you want to send,
including any headers passed in. For example:

```elixir
defmodule MyModule do
  def add_aws_signature(request, region) do
    [{"Authorization", generate_aws_signature(request, region)} | request.headers]
  end

  defp generate_aws_signature(request, region) do
    # See: https://github.com/bryanjos/aws_auth or similar
  end
end
```

The above for example will
  * lead to the HTTPoison responses being parsed into maps with atom keys instead of string keys (be careful as most of the time this is not a good idea as stated here: https://github.com/devinus/poison#parser).
  * use shield for authentication

## Running tests

You need elastic search running locally on port 9200. A quick way of running any version of elastic, is via docker:

```
$ docker run -p 9200:9200 -it --rm elasticsearch:5.1.2
```

Then clone the repo and fetch its dependencies:

```
$ git clone git@github.com:evuez/rubber.git
$ cd rubber
$ mix deps.get
$ mix test
```

## License

[elastix](https://github.com/werbitzky/elastix) was first licensed under the WTFPL by El Werbitzky <werbitzky@gmail.com>.
Rubber is now distributed under the MIT License.
