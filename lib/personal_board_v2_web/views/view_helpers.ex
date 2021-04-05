defmodule PersonalBoardV2Web.ViewHelpers do
  @moduledoc """
  View Helpers used across the app.
  """
  use Phoenix.HTML
  alias PersonalBoardV2Web.Router.Helpers, as: Routes

  @spec format_date(Timex.Types.valid_datetime()) :: String.t() | no_return()
  def format_date(date) do
    Timex.format!(date, "{0D}/{0M}/{YYYY}")
  end

  @doc """
  Format the given number of seconds in hh:mm:ss.
  """
  def format_seconds(seconds) do
    seconds |> Timex.Duration.from_seconds() |> Timex.Duration.to_time!()
  end


  def icon_tag(socket, name, opts \\ []) do
    classes = Keyword.get(opts, :class, "") <> " icon"

    content_tag(:svg, class: classes) do
      tag(:use, "xlink:href": Routes.static_path(socket, "/images/icons.svg#" <> name))
    end
  end
end
