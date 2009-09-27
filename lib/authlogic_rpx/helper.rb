module AuthlogicRpx
	module Helper

		# helper to insert an embedded iframe RPX login
		# takes options hash:
		#   * <tt>app_name:</tt> name of the application (will be prepended to RPX domain and used in RPX dialogues)
		#   * <tt>return_url:</tt> url for the RPX callback (e.g. user_sessions_url)
		#   * <tt>add_rpx:</tt> if true, requests RPX callback to add to current session. Else runs normal authentication process (default)
		def rpx_embed(options = {})
			params = (
				{ :authenticity_token => form_authenticity_token, :add_rpx => options[:add_rpx] }.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
			).compact.join('&')
			RPXNow.embed_code(options[:app_name], u( options[:return_url] + '?' + params ) )
		end

		# helper to insert a link to pop-up RPX login
		# takes options hash:
		#   * <tt>link_text:</tt> text to use in the link
		#   * <tt>app_name:</tt> name of the application (will be prepended to RPX domain and used in RPX dialogues)
		#   * <tt>return_url:</tt> url for the RPX callback (e.g. user_sessions_url)
		#   * <tt>add_rpx:</tt> if true, requests RPX callback to add to current session. Else runs normal authentication process (default)
		def rpx_popup(options = {})
			params = (
				{ :authenticity_token => form_authenticity_token, :add_rpx => options[:add_rpx] }.collect { |n| "#{n[0]}=#{ u(n[1]) }" if n[1] }
			).compact.join('&')
			RPXNow.popup_code(
				options[:link_text], 
				options[:app_name],
				u( options[:return_url] + '?' + params ),
				:unobtrusive=>true
				) 
				# NB: i18n considerations? supports a :language parameter (not tested)
		end

	end
end