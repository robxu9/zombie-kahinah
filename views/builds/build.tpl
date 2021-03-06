{{template "header.tpl" .}}

      <div class="row">
        <div class="col-md-10 col-md-offset-1">
          <br/>
          {{if eq .Package.Status "testing"}}<div class="panel panel-warning">{{else}}
          {{if eq .Package.Status "rejected"}}<div class="panel panel-danger">{{else}}
          {{if eq .Package.Status "published"}}<div class="panel panel-success">{{else}}
          <div class="panel panel-primary">{{end}}{{end}}{{end}}
            <div class="panel-heading">
              <h1>{{.Package.Name}} <small>{{.SourceEVR}} ({{.Package.Architecture}}) {{.Package.BuildDate.Year}}-{{.Package.Id}}</small><div class="pull-right">{{.Karma}} {{if .KarmaControls}}<a href="#" class="btn" data-toggle="modal" data-target="#voteModal"><i class="fa fa-3x {{if .UserVote}}fa-check-square-o{{else}}fa-pencil-square-o{{end}}"></i></a>{{end}}</div></h1>
            </div>
            <table class="table table-condensed">
              <tbody>
                <tr>
                  <td><b>Submitter</b></td>
                  <td>{{.Package.Submitter.Email | emailat}}</td>
                </tr>
                <tr>
                  <td><b>Platform<b></td>
                  <td>{{.Package.Platform}}</td>
                </tr>
                <tr>
                  <td><b>Repository<b></td>
                  <td>{{.Package.Repo}}</td>
                </tr>
                <tr>
                  <td><b>URL<b></td>
                  <td><a href="{{.Url}}">{{.Url}}</a></td>
                </tr>
                <tr>
                  <td><b>Packages<b></td>
                  <td>
                    <table class="table table-bordered table-condensed table-responsive">
                      <tbody>
                        {{with .Package.Packages}}
                          {{range .}}
                        <tr>
                          <td>{{.Name}}-{{if gt .Epoch 0}}{{.Epoch}}:{{end}}{{.Version}}-{{.Release}}{{if .Arch}}.{{.Arch}}{{end}}.{{.Type}}</td>
                        </tr>
                          {{end}}
                        {{end}}
                      </tbody>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td><b>Build Date</b></td>
                  <td>{{.Package.BuildDate}}</td>
                </tr>
                <tr>
                  <td><b>Last Updated</b></td>
                  <td>{{.Package.Updated}}</td>
                </tr>
            </table>
          </div>
        </div>
      </div>

      <!-- diff & changelog -->
      <div class="row">
        <div class="col-md-10 col-md-offset-1">

          <div class="panel panel-info">
            <div class="panel-heading"><button class="btn btn-info" data-toggle="collapse" href="#diff">Git Diff</button><div class="pull-right"><a href="{{.Commits}}" class="btn btn-default">Commits</a></div></div>
            <div id="diff" class="panel-collapse collapse">
              <pre class="brush: diff">{{.Package.Diff}}</pre>
            </div>
          </div>

          <div class="panel panel-primary">
            <div class="panel-heading"><button class="btn btn-primary" data-toggle="collapse" href="#cnlog">Changelog</button></div>
            <div id="cnlog" class="panel-collapse collapse">
              <pre class="pre-scrollable">{{if .Changelog}}{{.Changelog}}{{else}}Not Available{{end}}</pre>
            </div>
          </div>

          <!-- want to test? -->
          {{if eq .Package.Status "testing"}}
          <div class="panel panel-warning">
            <div class="panel-heading"><button class="btn btn-warning" data-toggle="collapse" href="#testinfo">Want to test?</button></div>
            <div id="testinfo" class="panel-collapse collapse">
              <div class="panel-body">
                On your <code>{{.Package.Platform}}/{{.Package.Architecture}}</code> machine, enable the updates-testing repository for {{.Package.Repo}}. Then <code>urpmi.update -a</code> and <code>urpmi</code> the affected packages.<br/>
                When you're done, you can use <code>urpmi --downgrade</code> to revert back to previous versions.
              </div>
            </div>
          </div>
          {{end}}

          <div class="panel panel-default">
            <div class="panel-heading"><button class="btn btn-default">Karma</button></div>
            <div class="panel-body">
              {{if .Votes}}
              <table class="table table-condensed table-responsive table-bordered">
                {{with .Votes}}
                  {{range .}}
                <tr class="{{if eq .Value 1}}success{{end}}{{if eq .Value 2}}danger{{end}}{{if eq .Value 3}}info{{end}}{{if eq .Value 4}}warning{{end}}"><td>{{.Key.User.Email | emailat}}</td><td>{{if .Key.Comment}}{{.Key.Comment}}{{else}}<em>No Comment.</em>{{end}}</td><td>{{if .Key.Time}}{{.Key.Time | since}}{{else}}[voted before timekeeping began]{{end}}</td></tr>
                  {{end}}
                {{end}}
              </table>
              {{else}}
              No opinions... yet.
              {{end}}
            </div>
          </div>

        </div>
      </div>

      <!-- Vote Modal -->

      <div class="modal fade" id="voteModal" tabindex="-1" role="dialog">
        <div class="modal-dialog">
          <center>
            <div class="modal-content">
              <form class="form-inline" role="form" method="post" id="voteForm">
                {{ .xsrf_data }}
                <div class="modal-header">
                  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                  <h4 class="modal-title" id="Vote Modal">Cast Opinion</h4>
                </div>
                <div class="modal-body">
                  <div class="btn-group" data-toggle="buttons">
                    <label class="btn btn-default {{if eq .UserVote 0}}active{{end}}">
                      <input type="radio" name="type" value="Neutral" {{if eq .UserVote 0}}checked{{end}}><i class="fa fa-lg fa-meh-o"></i> No Vote
                    </label>
                    <label class="btn btn-danger {{if eq .UserVote -1}}active{{end}}">
                      <input type="radio" name="type" value="Down" {{if eq .UserVote -1}}checked{{end}}><i class="fa fa-lg fa-frown-o"></i> Reject
                    </label>
                    <label class="btn btn-success {{if eq .UserVote 1}}active{{end}}">
                      <input type="radio" name="type" value="Up" {{if eq .UserVote 1}}checked{{end}}><i class="fa fa-lg fa-smile-o"></i> Accept
                    </label>
                    {{if .MaintainerControls}}
                    <label class="btn btn-primary {{if eq .UserVote 2}}active{{end}}" {{if not .MaintainerTime}}disabled="disabled"{{end}}>
                      {{if .MaintainerTime}}<input type="radio" name="type" value="Maintainer" {{if eq .UserVote 2}}checked{{end}}>{{end}}<i class="fa fa-lg fa-thumbs-o-up"></i> Maintainer Push
                    </label>
                    {{end}}
                    {{if .QAControls}}
                    <label class="btn btn-warning">
                      <input type="radio" name="type" id="voteQADown" value="QABlock"><i class="fa fa-lg fa-thumbs-o-down"></i> QA Block
                    </label>
                    <label class="btn btn-warning">
                      <input type="radio" name="type" id="voteQAUp" value="QAPush"><i class="fa fa-lg fa-thumbs-o-up"></i> QA Push
                    </label>
                    <label class="btn btn-warning">
                      <input type="radio" name="type" id="voteQAClear" value="QAClear"><i class="fa fa-lg fa-scissors"></i> QA Clear
                    </label>
                    {{end}}
                    {{if .FinalizeControls}}
                    <label class="btn btn-info">
                        <input type="radio" name="type" id="voteFinalize" value="Finalize"><i class="fa fa-lg fa-flag-o"></i> Finalize
                    </label>
                    {{end}}
                  </div>
                </div>
                {{if .MaintainerControls}}{{if not .MaintainerTime}}
                <div class="alert alert-info"><b>This is your update!</b> Unfortunately, you need to wait {{.MaintainerHoursNeeded}} hours since the Build Date until you can activate Maintainer Accept.</div>
                {{else}}<div class="alert alert-info"><b>This is your update!</b> You can activate Maintainer Accept now.</div>{{end}}{{end}}
                <div id="voteModalAlertPlaceholder"></div>
                <div class="modal-body">
                  <div class="input-group">
                    <span class="input-group-addon"><i class="fa fa-lg fa-comment-o"></i> Comment</span>
                    <input type="text" class="form-control" name="comment" placeholder="It's recommended to say something." {{if .KarmaCommentPrev}}value="{{.KarmaCommentPrev}}"{{end}}>
                  </div>
                </div>
                <div class="modal-footer">
                  <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                  <button type="submit" type="button" class="btn btn-primary">Submit</button>
                </div>
              </form>
            </div>
          </center>
        </div>
      </div>

      <script>
        $("input").change(function() {
          if ($("#voteQADown").is(':checked')) {
            $('#voteModalAlertPlaceholder').html('<div class="alert alert-danger"><b>Heads up!</b> This adds -9999 karma and allows the build to be finalized immediately!</div>');
          } else if ($("#voteQAUp").is(':checked')) {
            $('#voteModalAlertPlaceholder').html('<div class="alert alert-warning"><b>Heads up!</b> This adds 9999 karma and allows the build to be finalized immediately!</div>');
          } else if ($("#voteQAClear").is(':checked')) {
            $('#voteModalAlertPlaceholder').html('<div class="alert alert-warning"><b>Beware:</b> This removes this update from being controlled by Kahinah. Useful if someone has bypassed via ABF.</div>');
          } else if ($("#voteFinalize").is(':checked')) {
            $('#voteModalAlertPlaceholder').html('<div class="alert alert-warning">After you finalize this update, it will be pushed to the main updates repositories. No more changes can be made.</div>');
          } else {
            $('#voteModalAlertPlaceholder').html('')
          }
        }).change();
      </script>

      <link href="{{url "/static/css/shCore.css"}}" rel="stylesheet" type="text/css" />
      <link href="{{url "/static/css/shThemeDefault.css"}}" rel="stylesheet" type="text/css" />

      <script src="{{url "/static/js/shCore.js"}}" type="text/javascript"></script>
      <script src="{{url "/static/js/shBrushDiff.js"}}" type="text/javascript"></script>
      <script>SyntaxHighlighter.all();</script>

{{template "footer.tpl" .}}
