{{- define "dummy-chart.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "dummy-chart.chart" -}}
{{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{- define "dummy-chart.labels" -}}
helm.sh/chart: {{ include "dummy-chart.chart" . }}
app.kubernetes.io/name:       {{ include "dummy-chart.name" . }}
app.kubernetes.io/instance:   {{ .Release.Name }}
app.kubernetes.io/version:    {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
