sub init()
    m.mediaList = m.top.findNode("mediaList")
    m.videoPlayer = m.top.findNode("videoPlayer")
    
    m.mediaList.observeField("itemSelected", "onItemSelected")
    
    m.feedTask = createObject("roSGNode", "FeedTask")
    m.feedTask.observeField("content", "onContentReady")
    m.feedTask.control = "RUN"
    
    m.mediaList.setFocus(true)
end sub

sub onContentReady()
    m.mediaList.content = m.feedTask.content
end sub

sub onItemSelected()
    row = m.mediaList.rowItemSelected[0]
    col = m.mediaList.rowItemSelected[1]
    selectedItem = m.mediaList.content.getChild(row).getChild(col)
    
    videoContent = createObject("RoSGNode", "ContentNode")
    
    if row = 2 
        PlayVideo(selectedItem.url, "hls")
    else
        extractUrl = "https://apiprorescue.tvymas.workers.dev/extract?url=" + selectedItem.url
        
        req = CreateObject("roUrlTransfer")
        req.SetUrl(extractUrl)
        req.SetCertificatesFile("common:/certs/ca-bundle.crt")
        req.InitClientCertificates()
        response = req.GetToString()
        
        if response <> ""
            jsonRes = ParseJson(response)
            if jsonRes <> invalid and jsonRes.stream <> invalid
                proxyFinalUrl = "https://apiprorescue.tvymas.workers.dev/proxyvideo?url=" + jsonRes.stream
                PlayVideo(proxyFinalUrl, "hls")
            end if
        end if
    end if
end sub

sub PlayVideo(url as String, format as String)
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = url
    videoContent.streamformat = format
    
    m.videoPlayer.content = videoContent
    m.videoPlayer.visible = true
    m.videoPlayer.setFocus(true)
    m.videoPlayer.control = "play"
end sub
