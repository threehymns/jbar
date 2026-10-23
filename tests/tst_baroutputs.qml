import QtQuick
import QtTest
import "../bar"

// The tests of the outputs of the bar.
//
// The filter of the outputs is a plain object without a bar, so the empty,
// matching, non-matching and partial lists are tested here.
TestCase {
    name: "BarOutputs"

    function test_an_empty_list_shows_every_output() {
        const plan = BarOutputs.plan("", ["eDP-1", "HDMI-A-1"])
        compare(plan.fallback, false)
        compare(plan.showAll, true)
        compare(BarOutputs.shows(plan, "eDP-1"), true)
        compare(BarOutputs.shows(plan, "DP-9"), true)
    }

    function test_a_matching_list_filters_the_outputs() {
        const plan = BarOutputs.plan("eDP-1, HDMI-A-1",
            ["eDP-1", "HDMI-A-1", "DP-2"])
        compare(plan.fallback, false)
        compare(plan.showAll, false)
        compare(plan.unmatched, [])
        compare(BarOutputs.shows(plan, "eDP-1"), true)
        compare(BarOutputs.shows(plan, "HDMI-A-1"), true)
        compare(BarOutputs.shows(plan, "DP-2"), false)
    }

    function test_a_non_matching_list_falls_back_to_every_output() {
        const plan = BarOutputs.plan("eDP-1, HDMI-A-1", ["eDP-2", "DP-1"])
        compare(plan.fallback, true)
        compare(plan.showAll, true)
        compare(plan.unmatched, ["eDP-1", "HDMI-A-1"])
        compare(BarOutputs.shows(plan, "eDP-2"), true)
        compare(BarOutputs.shows(plan, "DP-1"), true)
    }

    function test_a_partial_match_keeps_the_filter() {
        const plan = BarOutputs.plan("eDP-1, HDMI-A-1", ["eDP-1", "DP-1"])
        compare(plan.fallback, false)
        compare(plan.showAll, false)
        compare(plan.unmatched, ["HDMI-A-1"])
        compare(BarOutputs.shows(plan, "eDP-1"), true)
        compare(BarOutputs.shows(plan, "DP-1"), false)
    }

    function test_the_names_are_trimmed_and_empty_parts_are_ignored() {
        compare(BarOutputs.parse(" eDP-1 ,, HDMI-A-1 , "), ["eDP-1", "HDMI-A-1"])
    }

    function test_the_warning_names_the_unmatched_outputs() {
        const plan = BarOutputs.plan("eDP-1, HDMI-A-1", ["DP-1"])
        verify(BarOutputs.warning(plan).indexOf("eDP-1") !== -1)
        verify(BarOutputs.warning(plan).indexOf("HDMI-A-1") !== -1)
        compare(BarOutputs.warning(BarOutputs.plan("", ["DP-1"])), "")
    }
}
