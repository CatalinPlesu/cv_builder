class MasterCvController < ApplicationController
  def index
    @full_name = "Catalin Plesu"
    @heading = [
      { icon: "mobile", text: "+373 67 655 472", url: "tel:+37367655472" },
      { icon: "at", text: "catalin.plesu@proton.me", url: "mailto:catalin.plesu@proton.me" },
      { icon: "square-linkedin", text: "linkedin", url: "https://www.linkedin.com/in/c%c4%83t%c4%83lin-ple%c8%99u-042872209/" },
      { icon: "Github", text: "github", url: "https://github.com/catalinplesu" },
      { icon: "globe", text: "site", url: "https://catalinplesu.xyz" },
      { icon: "map-marker", text: "Chișinău, Moldova", url: nil }
    ]

    @tags = [
      { name: "frontend", color: "#FF5733" },
      { name: "backend", color: "#33FF57" },
      { name: "core", color: "#3357FF" }
    ]
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
end
