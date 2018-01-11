# Rubber [![Build Status](https://travis-ci.org/evuez/rubber.svg?branch=master)](https://travis-ci.org/evuez/rubber)

A simple Elastic client written in Elixir.

[elastix](https://github.com/werbitzky/elastix) doesn't seem to be maintained anymore so I'll try to keep this fork up-to-date.

I started off with `elastic-reloaded` for the name but then it got annoying because I wanted some consistency between the package name, the app name and the top module name so now it's `Rubber` everywhere.

## Preface

* [Latest Elastic docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)

This library talks to the Elasticsearch server through the HTTP API.
Most of its functions return an [HTTPoison](https://github.com/edgurgel/httpoison) request object.

When needed, the payload can be provided as an Elixir Map, which is internally converted to JSON. The library does not assume anything else regarding the payload and doesn't validate it before sending it to Elasticsearch.

## Overview

Rubber has 6 modules, 5 of them match the Elasticsearch API (`Index`, `Document`, `Search`, `Bulk` and `Mapping`) and the last module `HTTP` is meant for any request that can't be done with any of the aforementioned module.

Checkout their respective documentation for more information.

## Installation

Add `rubber` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:rubber, "~> 0.6"}]
end
```

## Examples

### Creating an Elastic index

```elixir
Rubber.Index.create("http://127.0.0.1:9200", "sample_index_name", %{})
```

### Map, Index, Search and Delete

```elixir
elastic_url = "http://127.0.0.1:9200"

data = %{
    user: "kimchy",
    post_date: "2009-11-15T14:12:12",
    message: "trying out Rubber"
}

mapping = %{
  properties: %{
    user: %{type: "text"},
    post_date: %{type: "date"},
    message: %{type: "text"}
  }
}

Rubber.Mapping.put(elastic_url, "twitter", "tweet", mapping)
Rubber.Document.index(elastic_url, "twitter", "tweet", product.id, data)
Rubber.Search.search(elastic_url, "twitter", ["tweet"], %{})
Rubber.Document.delete(elastic_url, "twitter", "tweet", product.id)
```

### Bulk requests

Bulk requests take as parameter a list of the lines you want to send to the [`_bulk`](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html) endpoint.

You can also specify the following options:

* `index` the index of the request
* `type` the document type of the request. *(you can't specify `type` without specifying `index`)*

```elixir
lines = [
  %{index: %{_id: "1"}},
  %{field: "value1"},
  %{index: %{_id: "2"}},
  %{field: "value2"}
]

Rubber.Bulk.post(elastic_url, lines, index: "my_index", type: "my_type")

# You can also send raw data:
data = Enum.map(lines, fn line -> Poison.encode!(line) <> "\n" end)
Rubber.Bulk.post_raw(elastic_url, data, index: "my_index", type: "my_type")
```

## Configuration

### [Shield](https://www.elastic.co/products/shield)

```elixir
config :rubber,
  shield: true,
  username: "username",
  password: "password",
```

### [Poison](https://github.com/devinus/poison) and [HTTPoison](https://github.com/edgurgel/httpoison)

```elixir
config :rubber,
  poison_options: [keys: :atoms!],
  httpoison_options: [hackney: [pool: :rubber_pool]]
```

### Custom headers

```elixir
config :rubber,
  custom_headers: {MyModule, :add_aws_signature, ["us-east"]}
```

`custom_headers` must be a tuple of the type `{Module, :function, [args]}`, where `:function` is a function that should accept the request (a map of this type: `%{method: String.t, headers: [], url: String.t, body: String.t}`) as its first parameter and return a list of the headers you want to send:

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

## Running tests

You need Elasticsearch running locally on port 9200. A quick way of doing so is via Docker:

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
