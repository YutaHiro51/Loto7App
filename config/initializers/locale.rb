# アプリケーションのデフォルトロケールを:jaに設定
Rails.application.config.i18n.default_locale = :ja

# 利用可能なロケールを[:ja]に制限
Rails.application.config.i18n.available_locales = [:ja]