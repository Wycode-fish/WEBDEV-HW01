defmodule TaskTrackerWeb.PageController do
  use TaskTrackerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  # def feed(conn, _params) do
  #   posts = TaskTracker.Tracker.list_posts()
  #   changeset = TaskTracker.Tracker.change_post(%TaskTracker.Tracker.Task{})
  #   render conn, "feed.html", posts: posts, changeset: changeset
  # end
end
