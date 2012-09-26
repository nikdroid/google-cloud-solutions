<%@page import="com.google.cloud.demo.model.PhotoManager"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"
  isELIgnored="false"%>

<%@ page import="java.util.ArrayList"%>
<%@ page import="com.google.cloud.demo.*"%>
<%@ page import="com.google.cloud.demo.model.*"%>
<%@ page import="com.google.appengine.api.users.*"%>

<%
  UserService userService = UserServiceFactory.getUserService();
  AppContext appContext = AppContext.getAppContext();
  ConfigManager configManager = appContext.getConfigManager();
  DemoUser currentUser = appContext.getCurrentUser();
  PhotoServiceManager serviceManager = appContext.getPhotoServiceManager();
  PhotoManager photoManager = appContext.getPhotoManager();
  CommentManager commentManager = appContext.getCommentManager();
%>
<!DOCTYPE html>

<head>
<script type="text/javascript">
function togglePhotoPost(expanded) {
  if (expanded) {
    document.getElementById("btn-choose-image").style.display="none";
    document.getElementById("upload-form").style.display="block";
  } else {
    document.getElementById("btn-choose-image").style.display="inline-block";
    document.getElementById("upload-form").style.display="none";
  }
}

function toggleCommentPost(id, expanded) {
  if (expanded) {
    document.getElementById("comment-input-" + id).setAttribute("class", "post-comment expanded");
    document.getElementById("comment-submit-" + id).style.display="inline-block";
    document.getElementById("comment-cancel-" + id).style.display="inline-block";
  } else {
    document.getElementById("comment-input-" + id).setAttribute("class", "post-comment collapsed");
    document.getElementById("comment-submit-" + id).style.display="none";
    document.getElementById("comment-cancel-" + id).style.display="none";
  }
}
</script>
<title>Photofeed</title>
<link rel="stylesheet" type="text/css" href="photofeed.css" />
</head>

<body>
  <div class="wrap">

    <div class="header group">
      <h1>
        <img src="img/photofeed.png" alt="Photofeed" />
      </h1>
      <div class="glow"></div>
    </div>

    <div id="upload-wrap">
      <div id="upload">
        <div class="account group">
          <div id="account-thumb">
            <img
              src="<%= ServletUtils.getUserIconImageUrl(currentUser.getUserId()) %>"
              alt="Unknown User Icon" />
          </div>
          <!-- /#account-thumb -->
          <div id="account-name">
            <h2><%= ServletUtils.getProtectedUserNickname(currentUser.getNickname()) %></h2>
            <p><%= currentUser.getEmail() %>
              | <a
                href=<%= userService.createLogoutURL(configManager.getMainPageUrl())%>>Sign
                out</a>
            </p>
          </div>
          <!-- /#account-name -->
        </div>
        <!-- /.account -->
        <a id="btn-choose-image" class="active btn" onclick="togglePhotoPost(true)">Choose an image</a>
        <div id="upload-form" style="display:none">
          <form action="<%= serviceManager.getUploadUrl() %>" method="post"
            enctype="multipart/form-data">
            <input class="inactive file btn" type="file" name="photo">
            <textarea name="title" placeholder="Write a description"></textarea>
            <input class="active btn" type="submit" value="Post">
            <a class="cancel" onclick="togglePhotoPost(false)">Cancel</a>
          </form>
        </div>
      </div>
      <!-- /#upload -->
    </div>
    <!-- /#upload-wrap -->

    <!-- KK -->
    <%
      Iterable<Photo> photoIter = photoManager.getActivePhotos();
      ArrayList<Photo> photos = new ArrayList<Photo>();
      for (Photo photo : photoIter) {
        photos.add(photo);
      }      
      int count = 0;
      for (Photo photo : photos) {
        String firstClass = "";
        String lastClass = "";
        if (count == 0) {
          firstClass = "first";
        }
        if (count == photos.size() - 1) {
          lastClass = "last";        
        }
    %>
    <div class="feed <%= firstClass %> <%= lastClass %>">
      <div class="post group">
        <div class="image-wrap">
          <img class="photo-image"
            src="<%= serviceManager.getImageDownloadUrl(photo)%>"
            alt="Photo Image" />
        </div>
        <div class="owner group">
          <img src="<%= ServletUtils.getUserIconImageUrl(photo.getOwnerId()) %>"
            alt="" />
          <div class="desc">
            <h3><%= ServletUtils.getProtectedUserNickname(photo.getOwnerNickname()) %></h3>
            <p><%= photo.getTitle() %>
            <p>
            <p class="timestamp"><%= ServletUtils.formatTimestamp(photo.getUploadTime()) %></p>
          </div>
          <!-- /.desc -->
        </div>
        <!-- /.usr -->
      </div>
      <!-- /.post -->
      <%
        Iterable<Comment> comments = commentManager.getComments(photo);
        for (Comment comment : comments) {
    %>
      <div class="post group">
        <div class="usr">
          <img
            src="<%= ServletUtils.getUserIconImageUrl(comment.getCommentOwnerId()) %>"
            alt="" />
          <div class="comment">
            <h3><%= ServletUtils.getProtectedUserNickname(comment.getCommentOwnerName()) %></h3>
            <p><%= comment.getContent() %>
            <p>
            <p class="timestamp"><%= ServletUtils.formatTimestamp(comment.getTimestamp()) %></p>
          </div>
          <!-- /.comment -->
        </div>
        <!-- /.usr -->
      </div>
      <!-- /.post -->

      <%
        }
    %>
      <div class="post group">
        <div class="usr last">
          <img
            src="<%= ServletUtils.getUserIconImageUrl(currentUser.getUserId()) %>"
            alt="" />
          <div class="comment">
            <h3><%= ServletUtils.getProtectedUserNickname(currentUser.getNickname()) %></h3>
            <form action="<%= configManager.getCommentPostUrl() %>"
              method="post">
              <input type="hidden" name="user" value="<%= photo.getOwnerId()%>" />
              <input type="hidden" name="id" value="<%= photo.getId()%>" />
              <textarea id="comment-input-<%= count %>" class="post-comment collapsed" name="comment"
                placeholder="Post a comment" onclick="toggleCommentPost(<%= count%>, true)"></textarea>
              <input id="comment-submit-<%= count %>" class="inactive btn" style="display:none"
                type="submit" name="send" value="Post comment">
              <a id="comment-cancel-<%= count %>" class="cancel" style="display:none"
                onclick="toggleCommentPost(<%= count %>, false)">Cancel</a>
            </form>
          </div>
          <!-- /.comment -->
        </div>
        <!-- /.usr -->
      </div>
      <!-- /.post -->
    </div>
    <!-- /.feed -->
    <%
        count++;
      }
    %>
  </div>
  <!-- /.wrap -->
</body>
</html>