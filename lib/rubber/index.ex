defmodule Rubber.Index do
  @moduledoc """
  The indices APIs are used to manage individual indices, index settings, aliases, mappings, and index templates.

  [Elastic documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices.html)
  """
  import Rubber.HTTP, only: [prepare_url: 2]
  alias Rubber.HTTP

  @doc """
  Creates a new index.

  ## Examples

      iex> Rubber.Index.create("http://localhost:9200", "twitter", %{})
      {:ok, %HTTPoison.Response{...}}
  """
  @spec create(elastic_url :: String.t, name :: String.t, data :: map) :: HTTP.resp
  def create(elastic_url, name, data) do
    prepare_url(elastic_url, name)
    |> HTTP.put(Poison.encode!(data))
  end

  @doc """
  Deletes an existing index.

  ## Examples

      iex> Rubber.Index.delete("http://localhost:9200", "twitter")
      {:ok, %HTTPoison.Response{...}}
  """
  @spec delete(elastic_url :: String.t, name :: String.t) :: HTTP.resp
  def delete(elastic_url, name) do
    prepare_url(elastic_url, name)
    |> HTTP.delete
  end

  @doc """
  Fetches info about an existing index.

  ## Examples

      iex> Rubber.Index.get("http://localhost:9200", "twitter")
      {:ok, %HTTPoison.Response{...}}
  """
  @spec get(elastic_url :: String.t, name :: String.t) :: HTTP.resp
  def get(elastic_url, name) do
    prepare_url(elastic_url, name)
    |> HTTP.get
  end

  @doc """
  Returns `true` if the specified index exists, `false` otherwise.

  ## Examples

      iex> Rubber.Index.exists?("http://localhost:9200", "twitter")
      {:ok, false}
      iex> Rubber.Index.create("http://localhost:9200", "twitter", %{})
      {:ok, %HTTPoison.Response{...}}
      iex> Rubber.Index.exists?("http://localhost:9200", "twitter")
      {:ok, true}
  """
  @spec exists?(elastic_url :: String.t, name :: String.t) :: HTTP.resp
  def exists?(elastic_url, name) do
    case prepare_url(elastic_url, name) |> HTTP.head do
      {:ok, response} ->
        case response.status_code do
          200 -> {:ok, true}
          404 -> {:ok, false}
        end
      err -> err
    end
  end

  @doc """
  Forces the [refresh](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html)
  of the specified index.

  ## Examples

      iex> Rubber.Index.refresh("http://localhost:9200", "twitter")
      {:ok, %HTTPoison.Response{...}}
  """
  @spec refresh(elastic_url :: String.t, name :: String.t) :: HTTP.resp
  def refresh(elastic_url, name) do
    prepare_url(elastic_url, [name, "_refresh"])
    |> HTTP.post("")
  end
end
