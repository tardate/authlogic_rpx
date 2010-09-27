module AuthlogicRpx
  module Helper

    # helper to insert an embedded iframe RPX login
    # takes options hash:
    #   * <tt>app_name:</tt> name of the application (will be prepended to RPX domain and used in RPX dialogues)
    #   * <tt>return_url:</tt> url for the RPX callback (e.g. user_sessions_url)
    #   * <tt>add_rpx:</tt> if true, requests RPX callback to add to current session. Else runs normal authentication process (default)
    #
    # The options hash may include other options as supported by rpx_now (see http://github.com/grosser/rpx_now)
    #
    def rpx_embed(options = {})
      app_name = options.delete( :app_name )
      token_url = build_token_url!( options )
      html = RPXNow.embed_code(app_name, token_url, options )
      if defined? raw
        raw html
      else
        html
      end
    end

    # helper to insert a link to pop-up RPX login
    # takes options hash:
    #   * <tt>link_text:</tt> text to use in the link
    #   * <tt>app_name:</tt> name of the application (will be prepended to RPX domain and used in RPX dialogues)
    #   * <tt>return_url:</tt> url for the RPX callback (e.g. user_sessions_url)
    #   * <tt>add_rpx:</tt> if true, requests RPX callback to add to current session. Else runs normal authentication process (default)
    #   * <tt>unobtrusive:</tt> true/false; sets javascript style for link. Default: true
    #
    # The options hash may include other options as supported by rpx_now (see http://github.com/grosser/rpx_now)
    #
    def rpx_popup(options = {})
      options = { :unobtrusive => true, :add_rpx => false }.merge( options )
      app_name = options.delete( :app_name )
      link_text = options.delete( :link_text )
      token_url = build_token_url!( options )
      html = RPXNow.popup_code( link_text, app_name,	token_url, options	)
      if defined? raw
        raw html
      else
        html
      end
    end

  private

    def build_token_url!( options )
      options.delete( :return_url ) + '?' + (
        { :authenticity_token => form_authenticity_token, :add_rpx => options.delete( :add_rpx ) }.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
      ).compact.join('&')
    end
  end
end