# frozen_string_literal: true

module IconScraper
  AUTHORITIES = {
    bayside: {
      url: "https://eplanning.bayside.nsw.gov.au/ePlanning/Pages/XC.Track",
      period: "thismonth",
      types: [217]
    },
    blue_mountains: {
      url: "https://www2.bmcc.nsw.gov.au/DATracking/Pages/XC.Track",
      period: "last14days"
    },
    boroondara: {
      url: "https://eservices.boroondara.vic.gov.au/EPlanning/Pages/XC.Track",
      period: "thismonth",
      types: %w[PlnPermit PlnAppeals PlnPostPer PlanPermGr PlanAmend PlanAppeal]
    },
    canada_bay: {
      url: "https://canadabay-eplanning.t1cloud.com/Pages/XC.Track",
      period: "last14days"
    },
    central_highlands: {
      url: "https://track.chrc.qld.gov.au/Pages/XC.Track",
      period: "last28days",
      types: [205, 400, 401, 402, 403, 405]
    },
    coffs_harbour: {
      url: "https://chcc-icon.saas.t1cloud.com/public/Pages/xc.Track",
      period: "last14days"
    },
    cumberland: {
      url: "https://cumberland-eplanning.t1cloud.com/Pages/XC.Track",
      period: "last14days"
    },
    georges_river: {
      url: "https://etrack.georgesriver.nsw.gov.au/Pages/XC.Track",
      period: "thismonth"
    },
    gosnells: {
      url: "http://apps.gosnells.wa.gov.au/ICON/Pages/XC.Track",
      period: "last14days"
    },
    greater_hume: {
      url: "http://datracker.greaterhume.nsw.gov.au/Pages/XC.Track",
      period: "last28days"
    },
    hobart: {
      url: "https://apply.hobartcity.com.au/Pages/XC.Track",
      period: "last14days",
      types: ["PLN"]
    },
    hornsby: {
      url: "http://hscenquiry.hornsby.nsw.gov.au/Pages/XC.Track",
      period: "last14days",
      ssl_verify: false
    },
    kyogle: {
      url: "https://etrack.kyogle.nsw.gov.au/Pages/XC.Track",
      period: "last28days"
    },
    leichhardt: {
      url: "http://www.eservices.lmc.nsw.gov.au/ApplicationTracking/Pages/XC.Track",
      period: "last14days",
      types: [161]
    },
    liverpool: {
      url: "https://eplanning.liverpool.nsw.gov.au/Pages/XC.Track",
      period: "last14days"
    },
    mackay: {
      url: "https://planning.mackay.qld.gov.au/Pages/XC.Track",
      period: "last28days"
    },
    mosman: {
      url: "http://portal.mosman.nsw.gov.au/Pages/XC.Track",
      period: "last14days",
      types: [8, 5]
    },
    northern_beaches: {
      url: "https://eservices.northernbeaches.nsw.gov.au/ePlanning/live/Public/XC.Track",
      period: "thismonth",
      types: ["DevApp"],
      # The xml output is broken on northern beaches so we're hacking around it by
      # using a really hardcoded html scraper that currently only really works for
      # the northern beaches
      use_html_scraper: true
    },
    north_sydney: {
      url: "https://apptracking.northsydney.nsw.gov.au/Pages/XC.Track",
      period: "last14days"
    },
    penrith: {
      url: "https://datracker.penrithcity.nsw.gov.au/track/Pages/XC.Track",
      period: "last28days",
      types: %w[DA DevApp]
    },
    randwick: {
      url: "https://planning.randwick.nsw.gov.au/pages/xc.track.advanced",
      period: "last14days",
      types: [217]
    },
    redland: {
      url: "http://pdonline.redland.qld.gov.au/Pages/XC.Track",
      period: "last14days",
      types: %w[
        BD BW BA MC MCU OPW BWP APS
        MCSS OP EC SB SBSS PD BX ROL QRAL
      ]
    },
    richmond_valley: {
      url: "http://datracker.richmondvalley.nsw.gov.au/Pages/XC.Track",
      period: "last28days"
    },
    scenic_rim: {
      url: "https://srr-prod-icon.saas.t1cloud.com/Pages/XC.Track",
      period: "last28days"
    },
    strathfield: {
      url: "http://daenquiry.strathfield.nsw.gov.au/Pages/XC.Track",
      period: "last28days"
    },
    swan: {
      url: "https://elodge.swan.wa.gov.au/Pages/XC.Track",
      types: [282, 281, 283],
      period: "thisweek"
    },
    tweed: {
      url: "https://s1.tweed.nsw.gov.au/Pages/XC.Track",
      period: "thismonth",
      types: %w[DA CDC]
    },
    waverley: {
      url: "https://eservices.waverley.nsw.gov.au/Pages/XC.Track",
      period: "last14days",
      types: %w[A0 SP2A TPO B1 B1A FPS]
    },
    whitsunday: {
      url: "http://eplanning.whitsundayrc.qld.gov.au/Pages/XC.Track",
      period: "last28days"
    },
    willoughby: {
      url: "https://eplanning.willoughby.nsw.gov.au/pages/xc.track",
      period: "last28days",
      types: [
        "da01", "da01a", "da02a", "da03", "da05", "da06", "da07",
        "da10", "s96", "cc01a", "cc01b", "cc03", "cc04", "cd01a",
        "cd01b", "cd02", "cd04", "bcertu", "bcertr", "bcertc",
        "tvpa", "tvpa 2", "tvpa r"
      ]
    }
  }.freeze
end
