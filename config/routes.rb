Rails.application.routes.draw do
  resources(:users)

  get("/glossary", { to: "home#glossary" })
  get("/styleguide", { to: "home#styleguide" })

  resources(:missions) do
    member do
      put("order_deliverables")
    end

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

  namespace :api do
    namespace :v1 do
      resources :missions
    end
  end

  get("/auth", { to: "omniauth#authenticate" })
  put("/logout", { to: "omniauth#logout" })

  get("/auth/twitter/callback", { to: "omniauth#callback" })
  get("/auth/twitter/failure", { to: "omniauth#failure" })

  root({ to: "home#index" })
end
