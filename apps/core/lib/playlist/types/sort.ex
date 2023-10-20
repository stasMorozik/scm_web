defmodule Core.Playlist.Types.Sort do
  @moduledoc """

  """

  alias Core.Playlist.Types.Sort

  @type t :: %Sort{
    name: binary()    | none(),
    created: binary() | none(),
    updated: binary() | none()
  }

  defstruct name: nil, created: nil, updated: nil
end