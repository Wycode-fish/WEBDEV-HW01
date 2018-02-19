defmodule TaskTrackerWeb.Plugs.GetCurrentUser do
  import Plug.Conn
  import Phoenix.Controller

  # Below the pipeline
  def get_current_user(conn, _params) do
    # TODO: Move this function out of the router module.
    user_id = get_session(conn, :user_id)
    user = TaskTracker.Accounts.get_user(user_id || -1)
    IO.puts "*************"
    IO.inspect user;
    assign(conn, :current_user, user)
  end

end
