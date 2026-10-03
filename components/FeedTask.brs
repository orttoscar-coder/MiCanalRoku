sub init()
    m.top.functionName = "loadAllContent"
end sub

sub loadAllContent()
    rootNode = CreateObject("roSGNode", "ContentNode")
    
    ' 1. Cargar Películas desde tu ZonaAPI Pro
    apiRowMovies = CreateObject("roSGNode", "ContentNode")
    apiRowMovies.title = "Películas (ZonaAPI Pro)"
    
    apiUrlMovies = "https://apiprorescue.tvymas.workers.dev/list?type=movies&page=1"
    jsonMovies = FetchJson(apiUrlMovies)
    
    if jsonMovies <> invalid and jsonMovies.results <> invalid
        for each item in jsonMovies.results
            itemNode = CreateObject("roSGNode", "ContentNode")
            itemNode.title = item.title
            itemNode.hdposterurl = item.poster
            itemNode.url = item.url
            apiRowMovies.appendChild(itemNode)
        end for
    end if
    
    ' 2. Cargar Series desde tu ZonaAPI Pro
    apiRowShows = CreateObject("roSGNode", "ContentNode")
    apiRowShows.title = "Series (ZonaAPI Pro)"
    
    apiUrlShows = "https://apiprorescue.tvymas.workers.dev/list?type=tvshows&page=1"
    jsonShows = FetchJson(apiUrlShows)
    
    if jsonShows <> invalid and jsonShows.results <> invalid
        for each item in jsonShows.results
            itemNode = CreateObject("roSGNode", "ContentNode")
            itemNode.title = item.title
            itemNode.hdposterurl = item.poster
            itemNode.url = item.url
            apiRowShows.appendChild(itemNode)
        end for
    end if
    
    ' 3. Cargar TV en Vivo (Tu lista M3U de GitHub)
    m3uRow = CreateObject("roSGNode", "ContentNode")
    m3uRow.title = "TV Cable y Canales en Vivo"
    
    m3uUrl = "https://raw.githubusercontent.com/NOVAPSNew/Novaps/main/tv.m3u"
    m3uString = FetchNetworkContent(m3uUrl)
    
    if m3uString <> ""
        lines = m3uString.tokenize(chr(10))
        currentItem = invalid
        
        for each line in lines
            line = line.trim()
            if left(line, 7) = "#EXTINF"
                currentItem = CreateObject("roSGNode", "ContentNode")
                commaPos = line.instr(",")
                if commaPos > 0
                    currentItem.title = right(line, len(line) - commaPos - 1)
                else
                    currentItem.title = "Canal"
                end if
            else if left(line, 4) = "http" and currentItem <> invalid
                currentItem.url = line
                currentItem.streamformat = "hls"
                m3uRow.appendChild(currentItem)
                currentItem = invalid
            end if
        end for
    end if
    
    rootNode.appendChild(apiRowMovies)
    rootNode.appendChild(apiRowShows)
    rootNode.appendChild(m3uRow)
    m.top.content = rootNode
end sub

function FetchJson(url as String) as Object
    response = FetchNetworkContent(url)
    if response <> ""
        return ParseJson(response)
    end if
    return invalid
end function

function FetchNetworkContent(url as String) as String
    req = CreateObject("roUrlTransfer")
    req.SetUrl(url)
    req.SetCertificatesFile("common:/certs/ca-bundle.crt")
    req.InitClientCertificates()
    req.AddHeader("User-Agent", "NovaTV-Roku/3.5")
    return req.GetToString()
end function
