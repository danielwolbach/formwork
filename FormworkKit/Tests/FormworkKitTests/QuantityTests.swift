//
//  QuantityTests.swift
//  FormworkKitTests
//
//  Created by Daniel Wolbach on 18.09.26.
//

@testable import FormworkKit
import Testing

struct QuantityTests {
    @Test
    func storesBaseValue() {
        #expect(Quantity(1, in: .kilometers).base == 1000)
        #expect(Quantity(2, in: .hours).base == 7200)
        #expect(Quantity(1, in: .miles).base == 1609.344)
    }

    @Test
    func changingUnitKeepsAmount() {
        var quantity = Quantity(90, in: .minutes)

        quantity.unit = .hours

        #expect(quantity.value == 1.5)
    }

    @Test
    func settingValueUsesCurrentUnit() {
        var quantity = Quantity(1, in: .hours)

        quantity.value = 2
        quantity.unit = .minutes

        #expect(quantity.value == 120)
    }

    @Test
    func valueIsRoundedToFractionLength() {
        var quantity = Quantity(10, in: .kilograms)

        quantity.unit = .pounds

        #expect(quantity.value == 22)
        #expect(Quantity(1.234, in: .kilometers).value == 1.23)
    }

    @Test
    func valueSurvivesRoundTrip() {
        #expect(Quantity(22.5, in: .pounds).value == 22.5)
        #expect(Quantity(0.25, in: .miles).value == 0.25)
    }

    @Test(arguments: Quantity.Unit.allCases)
    func alternativesShareDimension(unit: Quantity.Unit) {
        #expect(unit.alternatives.contains(unit))
        #expect(unit.alternatives.allSatisfy { $0.dimension == unit.dimension })
    }

    @Test
    func alternativesCoverEachDimension() {
        #expect(Quantity.Unit.kilograms.alternatives == [.kilograms, .pounds])
        #expect(Quantity.Unit.minutes.alternatives == [.seconds, .minutes, .hours])
        #expect(Quantity.Unit.meters.alternatives == [.meters, .kilometers, .miles])
    }
}
