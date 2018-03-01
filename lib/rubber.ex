defmodule Rubber do
  @moduledoc """
  Rubber consists of several modules trying to match the Elasticsearch API, a
  `Rubber.HTTP` module for raw requests and a `Rubber.JSON` module that allows using a
  custom JSON library.

    - `Rubber.Bulk` -- the [Bulk API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html)
    - `Rubber.Document` -- the [Document API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs.html)
    - `Rubber.Index` -- the [Index API](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices.html)
    - `Rubber.Mapping` -- the [Mapping API](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping.html)
    - `Rubber.Search` -- the [Search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html)
  """

  @doc false
  def start, do: Application.ensure_all_started(:rubber)

  @doc false
  def config, do: Application.get_all_env(:rubber)

  @doc false
  def config(key, default \\ nil), do: Application.get_env(:rubber, key, default)
end
