module Nmi
  class Payment

    def initialize()
      @login = {}
      @order = {}
      @billing = {}
      @shipping = {}
      @responses = {}
    end

    def setLogin(username,password)
      @login['password'] = password
      @login['username'] = username
    end

    def setOrder(*args)
      @order = args[0]
    end

    def setBilling(*args)
      @billing = args[0]
    end

    def setShipping(*args)
      @shipping = args[0]
    end

    def doSale(amount, ccnumber, ccexp,cvv='')
      @ccnumber = ccnumber
      @ccexp = ccexp
      @cvv = cvv
      query = set_login_query + set_query
      query += "amount=" + URI.escape("%.2f" %amount) + "&"
      query += "type=sale"
      return doPost(query)
    end

    def addCustomer(ccnumber, ccexp, cvv='')
      @ccnumber = ccnumber
      @ccexp = ccexp
      @cvv = cvv
      query = set_login_query + set_query
      query << "customer_vault=add_customer"
      return doPost(query)
    end

    def updateCustomer(id)
      query = set_query
      query += "customer_vault_id=" + id.to_s + "&"
      query += "customer_vault=update_customer"
      return doPost(query)
    end

    def docharge(id,amount)
      query = ""
      query = query + "username=" + URI.escape(@login['username']) + "&"
      query += "password=" + URI.escape(@login['password']) + "&"
      query += "amount=" + amount.to_s + "&"
      if amount <= 0
        query += "type=validate" + "&"
      end
      query += "customer_vault_id=" + id.to_s

      return doPost(query)
    end

    def status(transaction_id)
      query = ""
      query = query + "username=" + URI.escape(@login['username']) + "&"
      query += "password=" + URI.escape(@login['password']) + "&"
      query += "transaction_id=" + transaction_id.to_s
      return doquery(query)
    end

    def doquery(query)
      data = build_http_request(QUERY,query)
      val = Hash.from_xml(data)
      return val
    end

    def set_login_query
      query = ""
      query += "ccnumber=" + URI.escape(@ccnumber) + "&"
      query += "ccexp=" + URI.escape(@ccexp) + "&"
      if (@cvv!='')
        query += "cvv=" + URI.escape(@cvv) + "&"
      end
      return query
    end

    def set_query
      query  = ""
      # Login Information
      query = query + "username=" + URI.escape(@login['username']) + "&"
      query += "password=" + URI.escape(@login['password']) + "&"
      # Order Information
      all_details = @billing.merge(@shipping).merge(@order)
      all_details.each do |key,value|
        query += key.to_s + "=" + URI.escape(value) + "&"
      end
      
      puts query.inspect
      #exit
      return query
    end

    def doPost(query)
      data = build_http_request(TRANSACTION_QUETRY,query)
      data = '"https://secure.nmi.com/api/transact.php?' + data
      uri = Addressable::URI.parse(data)
      @responses = uri.query_values
      return @responses['response']
    end

    def build_http_request(query,data_string)
      url = URI.parse "#{query}?#{data_string}"
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true# if url.scheme == "https"
      http.ssl_version = :SSLv3
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      request = Net::HTTP::Get.new("#{query}?#{data_string}")
      data = http.request(request)
      data =  data.body
      return data
    end

    def getResponses()
      return @responses
    end
  end
end