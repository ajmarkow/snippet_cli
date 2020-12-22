require 'tty-box'

      def show_banner()
        box = TTY::Box::frame(width:67, height:11, border: :thick, align: :left) do 
        "
        #####   #     # ### ######  ######  ####### ####### 
        #     # ##    #  #  #     # #     # #          #    
        #       # #   #  #  #     # #     # #          #    
         #####  #  #  #  #  ######  ######  #####      #    
              # #   # #  #  #       #       #          #    
        #     # #    ##  #  #       #       #          #    
         #####  #     # ### #       #       #######    #    CLI                                                                
        "
        end
        puts box
      end