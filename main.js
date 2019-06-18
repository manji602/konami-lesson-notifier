function postSlackMessage(attachments) {
  var token   = PropertiesService.getScriptProperties().getProperty("SLACK_API_TOKEN");
  var botName = PropertiesService.getScriptProperties().getProperty("BOT_NAME");
  var botIcon = PropertiesService.getScriptProperties().getProperty("BOT_ICON");
  var channel = PropertiesService.getScriptProperties().getProperty("CHANNEL");
  var message = PropertiesService.getScriptProperties().getProperty("MESSAGE_TITLE");
  
  var app = SlackApp.create(token);
  
  return app.postMessage(channel, message, {
    username: botName,
    icon_url: botIcon,
    attachments: JSON.stringify(attachments),
    unfurl_links: true
  });
}

function getLatestStoreTopic(storeId) {
  const TOPIC_LIST_ENDPOINT = "http://information.konamisportsclub.jp/newdesign/ajax/if_get_topic.php";
  const TOPIC_URL_FORMAT    = "http://information.konamisportsclub.jp/newdesign/storeInformation_TopicView.php?Facility_cd=%s&Topic_kbn=%s&Topic_cd=%s";

  var options = {
    "method": "post",
    "payload": {
      "facility_cd": storeId
    }
  };
  var response = JSON.parse(UrlFetchApp.fetch(TOPIC_LIST_ENDPOINT, options));
  
  var topicUrls = [];
  var topics    = [];
  
  for (var i = 0; i < response["topicList"].length; i++) {
    var topic = response["topicList"][i]

    var facilityCd = topic["FACILITY_CD"]
    var topicKbn   = topic["TOPIC_KBN"]
    var topicCd    = topic["TOPIC_CD"]

    var topicUrl = Utilities.formatString(TOPIC_URL_FORMAT, facilityCd, topicKbn, topicCd);
    topicUrls.push(topicUrl);
  }

  for (var i = 0; i < topicUrls.length; i++) {
    var topicUrl = topicUrls[i]
    var response = getTopicContent(topicUrl);
    
    if (isTargetContent(response)) {
      topics.push(response);
    }
  }
  
  return topics
}

function getTopicContent(topicUrl) {
  var options = {
    "method": "get"
  }
  
  var response = UrlFetchApp.fetch(topicUrl);
  var parser   = Parser.data(response.getContentText("UTF-8"));
  
  var title = parser.from("<h1>").to("</h1>").build();
  var body  = parser.from("<p class=\"linkurl\">").to("</p>").build();
  
  var formattedBody = body.replace(/[\r\n]+/g, "").replace(/<br\s*\/>/g, "\n");

  return {
    "title": title,
    "body": formattedBody,
    "url": topicUrl
  };
}

function isTargetContent(content) {
  var titleKeyword  = PropertiesService.getScriptProperties().getProperty("TITLE_KEYWORD");
  var targetLessons = PropertiesService.getScriptProperties().getProperty("TARGET_LESSONS").split(",");
  if (content["title"].match(new RegExp(titleKeyword))) {
    return true;
  }
  
  targetLessons.forEach(function(lesson, index) {
    if (content["title"].match(new RegExp(lesson)) || content["body"].match(new RegExp(lesson))) {
      return true;
    }
  });
  
  return false;
}

function formatStoreTopic(storeName, storeTopic) {
  const messageColor = "#36a64f";

  return storeTopic.map(function(content, index) {
    return {
      "author_name": storeName,
      "title": content["title"],
      "title_link": content["url"],
      "text": content["body"],
      "color": messageColor
    }
  });
}

function main() {
  const CURRENT_SHEET_NAME = PropertiesService.getScriptProperties().getProperty("CURRENT_SHEET_NAME");

  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  var sheet       = spreadsheet.getSheetByName(CURRENT_SHEET_NAME);

  const storeNameValues = sheet.getRange("A:A").getValues();
  const lastRow         = storeNameValues.filter(String).length;
  const fetchRowCount   = lastRow - 1;

  const beginRow = 2;
  const storeNameColumn  = 1;
  const storeIdColumn    = 2;
  const storeTopicColumn = 3;

  var storeNames  = sheet.getSheetValues(beginRow, storeNameColumn, fetchRowCount, 1);
  var storeIds    = sheet.getSheetValues(beginRow, storeIdColumn, fetchRowCount, 1);
  var storeTopics = sheet.getSheetValues(beginRow, storeTopicColumn, fetchRowCount, 1);
  
  for (var index = 0; index < fetchRowCount; index++) {
    var storeName  = storeNames[index][0].toString();
    var storeId    = storeIds[index][0].toString();
    var storeTopic = storeTopics[index][0].toString();
    
    var currentStoreTopic = getLatestStoreTopic(storeId);
    
    if (storeTopic !== JSON.stringify(currentStoreTopic)) {
      sheet.getRange(index + beginRow, storeTopicColumn).setValue(JSON.stringify(currentStoreTopic));
      var attachments = formatStoreTopic(storeName, currentStoreTopic);
      postSlackMessage(attachments);
    }
  }
}
