jQuery ->
  if $('#infinite-scrolling').length > 0
    $(window).on 'scroll', ->
      pre_url = $('a[rel="next"]').attr('href').split('?')
      domain = pre_url[0]
      query = pre_url[1].split('&')
      processed_url = [domain, query[query.length-1]].join('?')
      console.log($('a[rel="next"]'), domain, query, processed_url)
      if processed_url && document.scrollingElement.scrollTop > $(document).height() - $(window).height() - 200
          $('.pagination').html('<img src="/assets/ajax-loader.gif" alt="Loading..." title="Loading..." />')
          $.getScript processed_url
      return
    return
