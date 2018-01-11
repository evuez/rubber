defmodule Rubber do
  @moduledoc false

  @doc false
  def start do
    :application.ensure_all_started(:rubber)
  end

  @doc false
  def config, do: Application.get_all_env(:rubber)
  @doc false
  def config(key, default \\ nil),
    do: Application.get_env(:rubber, key, default)
end
