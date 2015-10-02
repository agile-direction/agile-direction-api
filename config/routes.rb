Rails.application.routes.draw do
  resources(:users, { only: [:index, :show] }) do
    member do
      get(:activity)
    end
  end

  get("/glossary", { to: "home#glossary" })
  get("/styleguide", { to: "home#styleguide" })

  resources(:missions) do
    member do
      put("order_deliverables")
      post("clone")
    end

    resources(:participants, { only: [:new, :create, :destroy] })

    resources(:deliverables) do
      member do
        put("order_requirements")
      end

      resources(:requirements) do
        member do
          put :start
          put :finish
        end
      end
    end
  end

  get("/auth", { to: "omniauth#authenticate" })
  put("/logout", { to: "omniauth#logout" })

  get("/auth/twitter/callback", { to: "omniauth#callback" })
  get("/auth/twitter/failure", { to: "omniauth#failure" })

  root({ to: "home#index" })
end
