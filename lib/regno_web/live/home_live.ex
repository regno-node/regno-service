defmodule RegnoWeb.HomeLive do
  use RegnoWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      
    end

    {:ok, assign(socket,
        self_path: Routes.home_path(socket, :page),
        new_version: false
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex grow h-full font-mono bg-white dark:bg-zinc-800">
      <div class="grow overflow-y-auto">
        <div class="dark:text-white max-w-screen-lg w-full mx-auto px-8 pt-8 pb-32 space-y-4">
          <div class="flex flex-col space-y-2 items-center pb-4 border-b border-gray-200
                    sm:flex-row sm:space-y-0 sm:justify-between">
            <%= live_redirect to: Routes.home_path(@socket, :page), aria_label: "go to home" do %>
              <img src="/images/regno.png" class="h-[50px]" alt="Regno"/>
            <% end %>
          </div>

          <div class="h-55" role="region" aria-label="monerod info">
            <%= live_render(@socket, RegnoWeb.MonerodGetInfoView, id: "getinfoview") %>
          </div>
    
          <div class="h-80" role="region" aria-label="sync info">
            <%= live_render(@socket, RegnoWeb.MonerodConnectionsView, id: "connectionsview") %>
          </div>
        </div>
      </div>
    </div>
    """
  end

end
