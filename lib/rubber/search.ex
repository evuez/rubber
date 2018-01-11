defmodule Rubber.Search do
  @moduledoc """
  [Elastic documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search.html)
  """
  import Rubber.HTTP, only: [prepare_url: 2]
  alias Rubber.HTTP

  @doc """
  Makes a request to the `_search` or the `_msearch` endpoint depending on the type of
  `data`.

  When passing a map for data, it'll make a simple search, but you can pass a list of
  header and body params to make a [multi search](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html).

  ## Examples

      iex> Rubber.Search.search("http://localhost:9200", "twitter", "tweet", %{query: %{term: %{user: "kimchy"}}})
      {:ok, %HTTPoison.Response{...}}
  """
  def search(elastic_url, index, types, data) when is_list(data),
    do: search(elastic_url, index, types, data, [])
  def search(elastic_url, index, types, data),
    do: search(elastic_url, index, types, data, [])

  @doc false
  def search(elastic_url, index, types, data, query_params, options \\ [])
  def search(elastic_url, index, types, data, query_params, options)
      when is_list(data) do

    data = Enum.reduce(data, [], fn d, acc -> ["\n", Poison.encode!(d) | acc] end)
           |> Enum.reverse()
           |> IO.iodata_to_binary()

    prepare_url(elastic_url, make_path(index, types, query_params, "_msearch"))
    |> HTTP.post(data, [], options)
  end
  def search(elastic_url, index, types, data, query_params, options) do
    prepare_url(elastic_url, make_path(index, types, query_params))
    |> HTTP.post(Poison.encode!(data), [], options)
  end

  @doc false
  def scroll(elastic_url, data, options \\ []) do
    prepare_url(elastic_url, "_search/scroll")
    |> HTTP.post(Poison.encode!(data), [], options)
  end

  @doc false
  def count(elastic_url, index, types, data),
    do: count(elastic_url, index, types, data, [])

  @doc false
  def count(elastic_url, index, types, data, query_params, options \\ []) do
    elastic_url <> make_path(index, types, query_params, "_count")
    |> HTTP.post(Poison.encode!(data), [], options)
  end

  @doc false
  def make_path(index, types, query_params, api_type \\ "_search") do
    path_root = "/#{index}"

    path = case types do
      [] -> path_root
      _ -> path_root <> "/" <> Enum.join types, ","
    end

    full_path = "#{path}/#{api_type}"

    case query_params do
      [] -> full_path
      _ -> add_query_params(full_path, query_params)
    end
  end

  @doc false
  defp add_query_params(path, query_params) do
    query_string = Enum.map_join query_params, "&", fn(param) ->
      "#{elem(param, 0)}=#{elem(param, 1)}"
    end

    "#{path}?#{query_string}"
  end
end
