// Copyright 2026 Hengfei Yang.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

enum Currency: String, CaseIterable, Identifiable, Codable {
    // Major Global Currencies
    case usd = "USD" // United States Dollar
    case eur = "EUR" // Euro
    case gbp = "GBP" // British Pound Sterling
    case jpy = "JPY" // Japanese Yen
    case cny = "CNY" // Chinese Yuan Renminbi

    // Asia-Pacific
    case krw = "KRW" // South Korean Won
    case inr = "INR" // Indian Rupee
    case aud = "AUD" // Australian Dollar
    case nzd = "NZD" // New Zealand Dollar
    case hkd = "HKD" // Hong Kong Dollar
    case sgd = "SGD" // Singapore Dollar
    case thb = "THB" // Thai Baht
    case myr = "MYR" // Malaysian Ringgit
    case idr = "IDR" // Indonesian Rupiah
    case php = "PHP" // Philippine Peso
    case vnd = "VND" // Vietnamese Dong
    case twd = "TWD" // Taiwan Dollar

    // Middle East & Africa
    case aed = "AED" // UAE Dirham
    case sar = "SAR" // Saudi Riyal
    case zar = "ZAR" // South African Rand
    case ils = "ILS" // Israeli Shekel
    case try_ = "TRY" // Turkish Lira
    case egp = "EGP" // Egyptian Pound

    // Americas
    case cad = "CAD" // Canadian Dollar
    case mxn = "MXN" // Mexican Peso
    case brl = "BRL" // Brazilian Real
    case ars = "ARS" // Argentine Peso
    case clp = "CLP" // Chilean Peso

    // Europe
    case chf = "CHF" // Swiss Franc
    case sek = "SEK" // Swedish Krona
    case nok = "NOK" // Norwegian Krone
    case dkk = "DKK" // Danish Krone
    case pln = "PLN" // Polish Zloty
    case czk = "CZK" // Czech Koruna
    case rub = "RUB" // Russian Ruble

    var id: String { rawValue }

    var name: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .cny: return "Chinese Yuan"
        case .krw: return "South Korean Won"
        case .inr: return "Indian Rupee"
        case .aud: return "Australian Dollar"
        case .nzd: return "New Zealand Dollar"
        case .hkd: return "Hong Kong Dollar"
        case .sgd: return "Singapore Dollar"
        case .thb: return "Thai Baht"
        case .myr: return "Malaysian Ringgit"
        case .idr: return "Indonesian Rupiah"
        case .php: return "Philippine Peso"
        case .vnd: return "Vietnamese Dong"
        case .twd: return "Taiwan Dollar"
        case .aed: return "UAE Dirham"
        case .sar: return "Saudi Riyal"
        case .zar: return "South African Rand"
        case .ils: return "Israeli Shekel"
        case .try_: return "Turkish Lira"
        case .egp: return "Egyptian Pound"
        case .cad: return "Canadian Dollar"
        case .mxn: return "Mexican Peso"
        case .brl: return "Brazilian Real"
        case .ars: return "Argentine Peso"
        case .clp: return "Chilean Peso"
        case .chf: return "Swiss Franc"
        case .sek: return "Swedish Krona"
        case .nok: return "Norwegian Krone"
        case .dkk: return "Danish Krone"
        case .pln: return "Polish Zloty"
        case .czk: return "Czech Koruna"
        case .rub: return "Russian Ruble"
        }
    }

    var flag: String {
        switch self {
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .jpy: return "🇯🇵"
        case .cny: return "🇨🇳"
        case .krw: return "🇰🇷"
        case .inr: return "🇮🇳"
        case .aud: return "🇦🇺"
        case .nzd: return "🇳🇿"
        case .hkd: return "🇭🇰"
        case .sgd: return "🇸🇬"
        case .thb: return "🇹🇭"
        case .myr: return "🇲🇾"
        case .idr: return "🇮🇩"
        case .php: return "🇵🇭"
        case .vnd: return "🇻🇳"
        case .twd: return "🇹🇼"
        case .aed: return "🇦🇪"
        case .sar: return "🇸🇦"
        case .zar: return "🇿🇦"
        case .ils: return "🇮🇱"
        case .try_: return "🇹🇷"
        case .egp: return "🇪🇬"
        case .cad: return "🇨🇦"
        case .mxn: return "🇲🇽"
        case .brl: return "🇧🇷"
        case .ars: return "🇦🇷"
        case .clp: return "🇨🇱"
        case .chf: return "🇨🇭"
        case .sek: return "🇸🇪"
        case .nok: return "🇳🇴"
        case .dkk: return "🇩🇰"
        case .pln: return "🇵🇱"
        case .czk: return "🇨🇿"
        case .rub: return "🇷🇺"
        }
    }

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .cny: return "¥"
        case .krw: return "₩"
        case .inr: return "₹"
        case .aud: return "A$"
        case .nzd: return "NZ$"
        case .hkd: return "HK$"
        case .sgd: return "S$"
        case .thb: return "฿"
        case .myr: return "RM"
        case .idr: return "Rp"
        case .php: return "₱"
        case .vnd: return "₫"
        case .twd: return "NT$"
        case .aed: return "د.إ"
        case .sar: return "﷼"
        case .zar: return "R"
        case .ils: return "₪"
        case .try_: return "₺"
        case .egp: return "E£"
        case .cad: return "C$"
        case .mxn: return "MX$"
        case .brl: return "R$"
        case .ars: return "ARS$"
        case .clp: return "CLP$"
        case .chf: return "CHF"
        case .sek: return "kr"
        case .nok: return "kr"
        case .dkk: return "kr"
        case .pln: return "zł"
        case .czk: return "Kč"
        case .rub: return "₽"
        }
    }

    var displayName: String {
        "\(flag) \(rawValue) - \(name)"
    }
}
