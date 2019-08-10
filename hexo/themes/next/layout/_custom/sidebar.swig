{#{% if site.tags.length > 1 %}#}
  {#<script type="text/javascript" charset="utf-8" src="{{ url_for('/js/tagcloud.js') }}"></script>#}
  {#<script type="text/javascript" charset="utf-8" src="{{ url_for('/js/tagcanvas.js') }}"></script>#}
  {#<div class="widget-wrap">#}
    {#<h3 class="widget-title">标签云</h3>#}
    {#<div id="myCanvasContainer" class="widget tagcloud">#}
      {#<canvas width="250" height="250" id="resCanvas" style="width: 250px;height250: px;border-radius: 50%;">#}
        {#{{ list_tags() }}#}
      {#</canvas>#}
    {#</div>#}
  {#</div>#}
{#{% endif %}#}
