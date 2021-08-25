(() => {
    class myWebsocketHandler {
      setupSocket() {
        let xpath = document.location.pathname;
        // let params = new URLSearchParams(document.location.search.substring(1));
        
        this.socket = new WebSocket("ws://localhost:4000/ws" + xpath + document.location.search)
  
        this.socket.addEventListener("message", (event) => {
          const pTag = document.createElement("p")

          const o = JSON.parse(event.data)

          pTag.innerHTML = o.msg + " -> " + o.tmpdata
  
          document.getElementById("main").append(pTag)
        })
  
        this.socket.addEventListener("close", () => {
          this.setupSocket()
        })
      }
  
      submit(event) {
        event.preventDefault()
        const input = document.getElementById("message")
        const input2 = document.getElementById("nickname")
        const message = input.value
        const nickname = input2.value
        input.value = ""
  
        this.socket.send(
          JSON.stringify({
            data: {nickname: nickname, message: message},
          })
        )
      }
    }
  
    const websocketClass = new myWebsocketHandler()
    websocketClass.setupSocket()
    
    document.getElementById("button")
      .addEventListener("click", (event) => websocketClass.submit(event))
  })()
